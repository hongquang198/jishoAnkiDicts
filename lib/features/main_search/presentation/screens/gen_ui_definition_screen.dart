import 'dart:async';
import 'dart:developer';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_routes.dart';
import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../injection.dart';
import '../../../../models/example_sentence.dart';
import '../../../../models/kanji.dart';
import '../../../../services/kanji_helper.dart';
import '../../../../services/llm/genui_catalog.dart';
import '../../../../services/llm_service.dart';
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

  // Local dictionary data
  late JishoDefinition _jishoDefinition;
  List<String> _hanViet = const [];
  late Future<List<Kanji>> _kanjiListFuture;
  List<ExampleSentence>? _examples;
  // Stable future reference so FutureBuilder-driven sections do not reset
  // (and replay their entry animations) on every streaming rebuild.
  Future<List<ExampleSentence>>? _examplesFuture;
  List<Widget> _pitchWidgets = const [];
  bool _localDataLoaded = false;

  // LLM gap-fill data (used only when local data is missing)
  Map<String, dynamic>? _llmInfo;

  // AI explanation stream
  String _accumulatedText = '';
  bool _isStreaming = false;
  bool _receivedA2uiContent = false;
  String? _errorMessage;
  StreamSubscription<String>? _subscription;
  StreamSubscription<core.A2uiMessage>? _messageSubscription;
  StreamSubscription<String>? _textSubscription;
  SurfaceController? _surfaceController;
  A2uiTransportAdapter? _transportAdapter;

  Divider get divider =>
      Divider(thickness: 0.4, color: Theme.of(context).dividerColor);

  String get currentJapaneseWord => widget.args.query.trim();

  @override
  void initState() {
    super.initState();
    _resolveBlocData();
    _kanjiListFuture =
        KanjiHelper.getKanjiComponent(word: currentJapaneseWord);
    _startStreaming();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadLocalDictionaryData());
  }

  void _resolveBlocData() {
    final data = widget.args.mainSearchBloc?.state.data;
    final query = currentJapaneseWord;
    _jishoDefinition = data?.getSpecificJishoDefinition(
          japaneseWord: query,
        ) ??
        data?.jishoDefinitionList.firstWhereOrNull(
              (element) =>
                  element.reading == query ||
                  element.slug == query ||
                  element.word == query,
            ) ??
        JishoDefinition(slug: '');
    _hanViet = data?.wordToHanVietMap[query] ?? const [];
  }

  /// Loads everything available from the local databases (mirroring
  /// [DefinitionScreen]) and fills any gaps via a single structured LLM call.
  Future<void> _loadLocalDictionaryData() async {
    // Pitch accent from local database.
    List<Widget> pitchWidgets = [];
    try {
      pitchWidgets = await KanjiHelper.getPitchAccent(
        word: currentJapaneseWord,
        slug: _jishoDefinition.slug,
        reading: _jishoDefinition.reading,
        context: context,
      );
    } catch (e) {
      log('Error getting pitch accent $e');
    }

    // Example sentences from local database (localized table first).
    if (!mounted) return;
    List<ExampleSentence> examples = [];
    try {
      final lang = getIt<SharedPref>().prefs.getString('language');
      if (lang?.contains('English') == true) {
        examples = await KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'englishExampleDictionary');
      } else if (lang == 'Tiếng Việt') {
        if (!mounted) return;
        examples = await KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'exampleDictionary');
        if (examples.isEmpty) {
          if (!mounted) return;
          examples = await KanjiHelper.getExampleSentence(
              word: currentJapaneseWord,
              context: context,
              tableName: 'englishExampleDictionary');
        }
      }
    } catch (e) {
      log('Error getting example sentence $e');
    }

    if (!mounted) return;
    setState(() {
      _pitchWidgets = pitchWidgets;
      _examples = examples;
      _examplesFuture = Future.value(examples);
      _localDataLoaded = true;
    });

    await _fillGapsFromLlm(pitchWidgets: pitchWidgets, examples: examples);
  }

  Future<void> _fillGapsFromLlm({
    required List<Widget> pitchWidgets,
    required List<ExampleSentence> examples,
  }) async {
    final needsLlm = _jishoDefinition.slug.isEmpty ||
        (_jishoDefinition.reading ?? '').isEmpty ||
        _hanViet.isEmpty ||
        pitchWidgets.isEmpty ||
        examples.isEmpty;
    if (!needsLlm) return;

    final sharedPref = getIt<SharedPref>();
    if (!sharedPref.llmEnable || sharedPref.llmApiKey.trim().isEmpty) return;

    final info = await getIt<LlmService>().fetchWordInfo(currentJapaneseWord);
    if (!mounted || info == null || info['found'] != true) return;
    setState(() {
      _llmInfo = info;
      // Swap the examples future only when the local list was empty and the
      // LLM actually provided sentences, so animations replay just once.
      if ((_examples?.isEmpty ?? true) && _effectiveExamples.isNotEmpty) {
        _examplesFuture = Future.value(_effectiveExamples);
      }
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

  void _startStreaming() {
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
    _textSubscription?.cancel();
    _transportAdapter?.dispose();
    _surfaceController?.dispose();

    setState(() {
      _accumulatedText = '';
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

    // Track non-A2UI text so we can fall back to raw rendering if the model
    // does not produce valid protocol messages.
    _textSubscription = _transportAdapter!.incomingText.listen((text) {
      if (mounted) {
        setState(() => _accumulatedText += text);
      }
    });

    // Create the surface deterministically on the client so it always exists,
    // regardless of what the model streams. The model only needs to supply
    // the updateComponents payload.
    _surfaceController!.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: _surfaceId,
        catalogId: genUiCatalogId,
      ),
    );

    final stream =
        llmService.generateExplanationStream(currentJapaneseWord, useGenUi: true);
    _subscription = stream.listen(
      (chunk) {
        if (mounted) {
          _transportAdapter?.addChunk(chunk);
          setState(() {});
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _errorMessage = error.toString();
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isStreaming = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _messageSubscription?.cancel();
    _textSubscription?.cancel();
    _transportAdapter?.dispose();
    _surfaceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVn = getIt<SharedPref>().isAppInVietnamese;

    return Scaffold(
      appBar: AppBar(
        title: _hasTagData
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
            : Text(
                currentJapaneseWord,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(left: 20, right: 20),
            icon: const Icon(Icons.refresh),
            tooltip: isVn ? 'Tạo lại' : 'Regenerate',
            onPressed: _isStreaming ? null : _startStreaming,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12),
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 10),
            _buildPitchAccentSection(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    currentJapaneseWord,
                    style: const TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_effectiveHanViet.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _effectiveHanViet.join(' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPitchAccentSection() {
    final pitchWidgets = _effectivePitchWidgets;
    if (pitchWidgets.isNotEmpty) {
      return Row(children: pitchWidgets);
    }
    if (!_localDataLoaded && _llmInfo == null) return const SizedBox.shrink();
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
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold),
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

    // The model never produced a valid A2UI payload; fall back to raw text
    // rendering instead of showing an empty surface.
    if (_isStreaming) return _buildLoadingIndicator(isVn);
    if (_accumulatedText.trim().isNotEmpty) {
      return _buildRawTextContent(context);
    }
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

  Widget _buildRawTextContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HtmlWidget(
          _markdownToSimpleHtml(_accumulatedText),
          textStyle: const TextStyle(fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              tooltip: 'Copy',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _accumulatedText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      getIt<SharedPref>().isAppInVietnamese
                          ? 'Đã sao chép vào bộ nhớ tạm!'
                          : 'Copied to clipboard!',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Simple converter to format markdown headers/bold text into HTML for HtmlWidget
  String _markdownToSimpleHtml(String markdown) {
    String text = markdown
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');

    text = text.replaceAllMapped(
        RegExp(r'\*\*(.*?)\*\*'), (match) => '<b>${match[1]}</b>');
    text = text.replaceAllMapped(
        RegExp(r'\*(.*?)\*'), (match) => '<i>${match[1]}</i>');
    text =
        text.replaceAllMapped(RegExp(r'`(.*?)`'), (match) => '<code>${match[1]}</code>');
    text = text.replaceAll('\n', '<br/>');
    return text;
  }
}
