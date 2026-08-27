import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/ai/ai_grammar_breakdown_card.dart';
import '../../../../common/widgets/ai/ai_memory_tip_card.dart';
import '../../../../common/widgets/ai/ai_tutor_card.dart';
import '../../../../config/app_routes.dart';
import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';
import '../../../../models/example_sentence.dart';
import '../../../../models/kanji.dart';
import '../../../../services/kanji_helper.dart';
import '../../../../services/llm/gen_ui_data_prefetch.dart';
import '../../../../services/llm/gen_ui_prefetch.dart';
import '../../../../services/llm/genui_catalog.dart';
import '../../../../services/llm_service.dart';
import '../../../../services/preloaded_image.dart';
import '../../../../services/wikimedia_image_service.dart';
import '../../../ai_chat/screens/ai_chat_screen.dart';
import '../../../main_search/domain/entities/jisho_definition.dart';
import '../bloc/main_search_bloc.dart';
import '../../../word_definition/screens/widgets/component_widget.dart';
import '../../../word_definition/screens/widgets/example_sentence_widget.dart';
import '../../../word_definition/screens/widgets/is_common_tag_and_jlpt.dart';

class GenUiDefinitionScreenArgs {
  final String query;
  final MainSearchBloc? mainSearchBloc;

  GenUiDefinitionScreenArgs({
    required this.query,
    this.mainSearchBloc,
  });
}

/// Resolves the bloc-held jisho definition and Sino-Vietnamese readings for
/// [query], shared by the search-result tile (prewarm) and this screen so the
/// matching logic exists exactly once.
({JishoDefinition jishoDefinition, List<String> hanViet}) resolveMainSearchData(
    MainSearchBloc? mainSearchBloc, String query) {
  final data = mainSearchBloc?.state.data;
  final jishoDefinition =
      data?.getSpecificJishoDefinition(japaneseWord: query) ??
          data?.jishoDefinitionList.firstWhereOrNull(
            (element) =>
                element.reading == query ||
                element.slug == query ||
                element.word == query,
          ) ??
          JishoDefinition(slug: '');
  final hanViet = data?.wordToHanVietMap[query] ?? const <String>[];
  return (jishoDefinition: jishoDefinition, hanViet: hanViet);
}

/// Loads localized example sentences for [query]: English table for English,
/// Vietnamese table first (with English fallback) for Tiếng Việt, nothing
/// otherwise.
Future<List<ExampleSentence>> loadLocalizedExamples(
  SharedPref sharedPref,
  String query,
) {
  final lang = sharedPref.prefs.getString('language');
  if (lang?.contains('English') == true) {
    return KanjiHelper.getExampleSentence(
      word: query,
      tableName: 'englishExampleDictionary',
    );
  }
  if (lang != 'Tiếng Việt') return Future.value(const []);
  return KanjiHelper.getExampleSentence(
    word: query,
    tableName: 'exampleDictionary',
  ).then((vnExamples) {
    if (vnExamples.isNotEmpty) return vnExamples;
    return KanjiHelper.getExampleSentence(
      word: query,
      tableName: 'englishExampleDictionary',
    );
  });
}

/// Wires [GenUiDataPrefetch.start] with the app's real services. Shared by
/// the search-result tile (tile-appear prewarm) and this screen (deep-link
/// fallback) so the lane wiring exists exactly once.
GenUiDataPrefetch startDefaultDataPrefetch({
  required String query,
  required JishoDefinition jishoDefinition,
}) {
  final sharedPref = getIt<SharedPref>();
  final llmService = getIt<LlmService>();
  return GenUiDataPrefetch.start(
    query: query,
    jishoDefinition: jishoDefinition,
    llmEnabled: sharedPref.llmEnable && sharedPref.llmApiKey.trim().isNotEmpty,
    fetchWordInfo: llmService.fetchWordInfo,
    searchThumbnailUrl: (term) => getIt<WikimediaImageService>()
        .fetchThumbnailUrl(term, width: kPrewarmThumbnailWidth),
    loadPitchWidgets: () => KanjiHelper.getPitchAccent(
      word: query,
      slug: jishoDefinition.slug,
      reading: jishoDefinition.reading,
    ),
    loadExamples: () => loadLocalizedExamples(sharedPref, query),
    loadKanjiComponents: () => KanjiHelper.getKanjiComponent(word: query),
  );
}

class GenUiDefinitionScreen extends StatefulWidget {
  final GenUiDefinitionScreenArgs args;

  const GenUiDefinitionScreen({
    super.key,
    required this.args,
  });

  @override
  State<GenUiDefinitionScreen> createState() => _GenUiDefinitionScreenState();
}

class _GenUiDefinitionScreenState extends State<GenUiDefinitionScreen> {
  static const _surfaceId = 'llm_definition_surface';

  final ScrollController _scrollController = ScrollController();

  // Local dictionary data
  late JishoDefinition _jishoDefinition;
  List<String> _hanViet = const [];
  late Future<List<Kanji>> _kanjiListFuture;
  List<ExampleSentence>? _examples;
  // Stable future reference so FutureBuilder-driven sections do not reset
  // (and replay their entry animations) on every streaming rebuild.
  Future<List<ExampleSentence>>? _examplesFuture;
  List<Widget> _pitchWidgets = const [];
  bool _pitchLaneDone = false;

  // LLM gap-fill data (used only when local data is missing)
  Map<String, dynamic>? _llmInfo;
  // True while the structured gap-fill payload (tutor comment, grammar
  // analysis) is still in flight, so placeholder spinners can be shown.
  bool _wordInfoPending = true;

  // Descriptive picture with bytes already decoded, and AI-tutor comment.
  PreloadedImage? _descriptivePicture;
  String? _aiTutorComment;
  String? _grammarAnalysis;
  String? _memoryTip;

  // AI explanation stream
  bool _isStreaming = false;
  bool _receivedA2uiContent = false;
  String? _errorMessage;
  StreamSubscription<String>? _subscription;
  StreamSubscription<core.A2uiMessage>? _messageSubscription;
  SurfaceController? _surfaceController;
  A2uiTransportAdapter? _transportAdapter;

  Divider get divider =>
      Divider(thickness: 0.4, color: Theme.of(context).dividerColor);

  String get currentJapaneseWord => widget.args.query.trim();

  @override
  void initState() {
    super.initState();
    _resolveBlocData();
    _attachDataPrefetch();
    _startStreaming();
  }

  void _resolveBlocData() {
    final resolved = resolveMainSearchData(
      widget.args.mainSearchBloc,
      currentJapaneseWord,
    );
    _jishoDefinition = resolved.jishoDefinition;
    _hanViet = resolved.hanViet;
  }

  /// Attaches to the pre-warmed lanes for this query (started by the
  /// search-result tile when it appeared). When missing — e.g. deep link —
  /// starts them fresh through the same wiring. Every future reference is
  /// assigned exactly once so streamed rebuilds never replay animations.
  void _attachDataPrefetch() {
    final query = currentJapaneseWord;
    final cache = getIt<GenUiDataPrefetchCache>();
    var prefetch = cache.get(query);
    if (prefetch == null) {
      final fresh = startDefaultDataPrefetch(
        query: query,
        jishoDefinition: _jishoDefinition,
      );
      cache.warm(query, start: () => fresh);
      prefetch = fresh;
    }

    _kanjiListFuture = prefetch.kanjiComponents;
    prefetch.pitchWidgets.then((widgets) {
      if (!mounted) return;
      setState(() {
        _pitchWidgets = widgets;
        _pitchLaneDone = true;
      });
    });
    prefetch.examples.then((examples) {
      if (!mounted) return;
      setState(() {
        _examples = examples;
        _examplesFuture = Future<List<ExampleSentence>>.value(examples);
      });
    });
    prefetch.wordInfo.then((info) {
      if (!mounted) return;
      setState(() {
        _wordInfoPending = false;
        if (info == null || info['found'] != true) return;
        _llmInfo = info;
        final comment = _llmString('tutorComment');
        if (comment.isNotEmpty) _aiTutorComment = comment;
        final grammar = _llmString('grammarAnalysis');
        if (grammar.isNotEmpty) _grammarAnalysis = grammar;
        final memoryTip = _llmString('memoryTip');
        if (memoryTip.isNotEmpty) _memoryTip = memoryTip;
        // Swap the examples future only when the local list was empty and
        // the LLM actually provided sentences, so animations replay once.
        if ((_examples?.isEmpty ?? true) && _effectiveExamples.isNotEmpty) {
          _examplesFuture =
              Future<List<ExampleSentence>>.value(_effectiveExamples);
        }
      });
    });
    prefetch.image.then((picture) {
      if (!mounted || picture == null) return;
      setState(() => _descriptivePicture = picture);
    });
  }

  // --- Effective values (local data preferred over LLM gap-fill) ---

  String get _effectiveReading {
    final reading = _jishoDefinition.reading;
    if (reading != null && reading.isNotEmpty) return reading;
    return _llmString('reading');
  }

  List<String> get _effectiveHanViet =>
      _hanViet.isNotEmpty ? _hanViet : _llmStringList('hanViet');

  List<Widget> get _effectivePitchWidgets {
    if (_pitchWidgets.isNotEmpty) return _pitchWidgets;
    final pattern = _llmString('pitchPattern');
    final reading = _effectiveReading;
    if (pattern.isEmpty || reading.isEmpty) return const [];
    return KanjiHelper.buildPitchWidgets(
        reading: reading, pitchPattern: pattern);
  }

  List<ExampleSentence> get _effectiveExamples {
    final local = _examples;
    if (local != null && local.isNotEmpty) return local;
    final raw = _llmInfo?['sentences'];
    if (raw is! List) return const [];
    return raw.map((item) {
      final map = item is Map<String, dynamic>
          ? item
          : (item as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      return ExampleSentence(
        jpSentence: map['jpSentence']?.toString() ?? '',
        targetSentence: map['targetSentence']?.toString() ?? '',
      );
    }).toList();
  }

  bool get _hasTagData =>
      _jishoDefinition.slug.isNotEmpty ||
      _llmInfo?['found'] == true ||
      _llmStringList('jlpt').isNotEmpty ||
      _llmStringList('tags').isNotEmpty;

  String _llmString(String key) =>
      _llmInfo?[key]?.toString().trim().isNotEmpty == true
          ? _llmInfo![key].toString()
          : '';

  List<String> _llmStringList(String key) {
    final value = _llmInfo?[key];
    return value is List ? value.map((e) => e.toString()).toList() : const [];
  }

  // --- AI explanation streaming ---

  /// Starts (or attaches to) the AI explanation stream.
  ///
  /// With [regenerate] the cached prefetch for this query is discarded first
  /// so a genuinely fresh request is issued; without it an in-flight or
  /// completed pre-warmed response is re-attached transparently.
  void _startStreaming({bool regenerate = false}) {
    final sharedPref = getIt<SharedPref>();
    final llmService = getIt<LlmService>();

    if (!sharedPref.llmEnable) return;
    if (sharedPref.llmApiKey.trim().isEmpty) {
      setState(() {
        _isStreaming = false;
        _errorMessage = 'missing_key';
      });
      return;
    }

    _subscription?.cancel();
    _messageSubscription?.cancel();
    _transportAdapter?.dispose();
    _surfaceController?.dispose();

    setState(() {
      _receivedA2uiContent = false;
      _errorMessage = null;
      _isStreaming = true;
    });

    _surfaceController = SurfaceController(catalogs: [genUiCatalog]);
    _transportAdapter = A2uiTransportAdapter();

    _messageSubscription = _transportAdapter!.incomingMessages.listen(
      (message) {
        if (!mounted) return;
        if (message is core.UpdateComponentsMessage) {
          _receivedA2uiContent = true;
        }
        _surfaceController?.handleMessage(message);
        setState(() {});
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _errorMessage = error.toString();
          });
        }
      },
    );

    // Create the surface deterministically on the client so it always exists,
    // regardless of what the model streams. The model only needs to supply
    // the updateComponents payload.
    _surfaceController!.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: _surfaceId,
        catalogId: genUiCatalogId,
      ),
    );

    // Attach to the pre-warmed GenUI response for this query (started by the
    // search-result tile when it appeared). If none exists — e.g. the screen
    // was opened without passing through the tile — this transparently starts
    // a fresh stream.
    final prefetchCache = getIt<GenUiPrefetchCache>();
    if (regenerate) prefetchCache.invalidate(currentJapaneseWord);
    prefetchCache.warm(
      currentJapaneseWord,
      startStream: () => llmService
          .generateExplanationStream(currentJapaneseWord, useGenUi: true),
    );
    final prefetch = prefetchCache.get(currentJapaneseWord)!;

    if (prefetch.error != null) {
      setState(() {
        _isStreaming = false;
        _errorMessage = prefetch.error;
      });
      return;
    }

    final attachment = prefetch.attach(
      (chunk) {
        if (!mounted) return;
        _transportAdapter?.addChunk(chunk);
        setState(() {});
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          if (prefetch.error != null) _errorMessage = prefetch.error;
        });
      },
    );
    _subscription = attachment.sub;
    if (attachment.snapshot.isNotEmpty) {
      _transportAdapter?.addChunk(attachment.snapshot);
    }
    if (prefetch.isDone) {
      setState(() => _isStreaming = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subscription?.cancel();
    _messageSubscription?.cancel();
    _transportAdapter?.dispose();
    _surfaceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVn = getIt<SharedPref>().isAppInVietnamese;
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool isSplitMode = screenHeight < 650;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: true,
            expandedHeight: 145,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: currentJapaneseWord,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      textDirection: TextDirection.ltr,
                    )..layout();

                    final offset = _scrollController.hasClients
                        ? _scrollController.offset
                        : 0.0;

                    final double maxScroll = 100.0;
                    final double progress =
                        (offset / maxScroll).clamp(0.0, 1.0);

                    final double startWidth = 0;
                    final double endWidth = textPainter.width;

                    final double dynamicWidth =
                        startWidth + (endWidth - startWidth) * progress;

                    return SizedBox(
                      width: dynamicWidth,
                      child: child,
                    );
                  },
                  child: Text(
                    currentJapaneseWord,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _hasTagData
                        ? IsCommonTagsAndJlptWidget(
                            isCommon: _jishoDefinition.isCommon ||
                                _llmInfo?['isCommon'] == true,
                            tags: _jishoDefinition.tags.isNotEmpty
                                ? _jishoDefinition.tags
                                : _llmStringList('tags'),
                            jlpt: _jishoDefinition.jlpt.isNotEmpty
                                ? _jishoDefinition.jlpt
                                : _llmStringList('jlpt'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.only(left: 10, right: 10),
                icon: const Icon(Icons.refresh),
                tooltip: isVn ? 'Tạo lại' : 'Regenerate',
                onPressed: _isStreaming
                    ? null
                    : () => _startStreaming(regenerate: true),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.fromLTRB(12, isSplitMode ? 50 : 98, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _buildPitchAccentSection(),
                          Text(
                            currentJapaneseWord,
                            style: const TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_effectiveHanViet.isNotEmpty)
                            Text(
                              _effectiveHanViet.join(' ').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    if (_descriptivePicture != null) ...[
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: _descriptivePicture!.provider,
                            height: 96,
                            width: 96,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                    ? child
                                    : const SizedBox(
                                        height: 96,
                                        width: 96,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFFDB8C8A)),
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 2),
                  Text(
                    isVn ? 'Giải thích AI' : 'AI Explanation',
                    style: const TextStyle(
                      color: Color(0xffDB8C8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAiBodyContent(isVn),
                  divider,
                  Text(
                    isVn ? 'Ví dụ' : 'Examples',
                    style: const TextStyle(
                      color: Color(0xffDB8C8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  _buildExamplesSection(isVn),
                  divider,
                  Text(
                    isVn ? 'Thành phần' : 'Components',
                    style: const TextStyle(
                      color: Color(0xffDB8C8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  ComponentWidget(kanjiComponent: _kanjiListFuture),
                  AiGrammarBreakdownCard(
                    grammarAnalysis: _grammarAnalysis,
                    isLoading: _wordInfoPending,
                  ),
                  AiTutorCard(
                    tutorComment: _aiTutorComment,
                    isLoading: _wordInfoPending,
                    errorMessage:
                        _errorMessage == 'missing_key' ? null : _errorMessage,
                    onAskAiTutor: () {
                      context.push(
                        AppRoutesPath.aiChat,
                        extra: AiChatScreenArgs(
                          word: currentJapaneseWord,
                          reading: _effectiveReading,
                          definition: _jishoDefinition.senses.isNotEmpty
                              ? _jishoDefinition.senses.first.englishDefinitions
                                  .join(', ')
                              : (_llmInfo?['senses'] is List &&
                                      (_llmInfo!['senses'] as List).isNotEmpty
                                  ? (((_llmInfo!['senses'] as List).first
                                                  as Map?)?[
                                              'english_definitions'] as List?)
                                          ?.join(', ') ??
                                      ''
                                  : ''),
                          existingTutorComment: _aiTutorComment,
                          existingMemoryTip: _memoryTip,
                        ),
                      );
                    },
                  ),
                  AiMemoryTipCard(
                    memoryTip: _memoryTip,
                    isLoading: _wordInfoPending,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPitchAccentSection() {
    final pitchWidgets = _effectivePitchWidgets;
    if (pitchWidgets.isNotEmpty) {
      return Row(children: pitchWidgets);
    }
    if (!_pitchLaneDone && _llmInfo == null) return const SizedBox.shrink();
    final reading = _effectiveReading;
    if (reading.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        reading,
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildExamplesSection(bool isVn) {
    final future = _examplesFuture;
    if (future == null) return const SizedBox.shrink();
    return ExampleSentenceWidget(
      exampleSentence: future,
    );
  }

  Widget _buildAiBodyContent(bool isVn) {
    if (_errorMessage == 'missing_key') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isVn
                      ? 'Chưa cấu hình Gemini API Key.'
                      : 'Gemini API Key is not set.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isVn
                ? 'Vui lòng truy cập Cài đặt để thêm Gemini API Key cá nhân của bạn.'
                : 'Please go to Settings to configure your personal Gemini API Key.',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDB8C8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              GoRouter.of(context).push(AppRoutesPath.settings);
            },
            icon: const Icon(Icons.settings, size: 16),
            label: Text(isVn ? 'Mở Cài đặt' : 'Open Settings'),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isVn
                ? 'Đã xảy ra lỗi khi kết nối AI:'
                : 'An error occurred while connecting to AI:',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 12, color: Colors.redAccent),
          ),
        ],
      );
    }

    if (_receivedA2uiContent) {
      return Surface(
        surfaceContext: _surfaceController!.contextFor(_surfaceId),
      );
    }

    if (_isStreaming) return _buildLoadingIndicator(isVn);
    return Text(
      isVn ? 'Không có câu trả lời.' : 'No output received.',
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildLoadingIndicator(bool isVn) {
    return Row(
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFDB8C8A),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isVn ? 'Đang phân tích từ vựng...' : 'Analyzing query...',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
