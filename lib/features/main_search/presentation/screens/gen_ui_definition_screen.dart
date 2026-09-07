import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/ai/ai_grammar_breakdown_card.dart';
import '../../../../common/widgets/ai/ai_memory_tip_card.dart';
import '../../../../common/widgets/ai/ai_tutor_card.dart';
import '../../../../config/app_routes.dart';
import '../../../../core/data/datasources/shared_pref.dart';
import '../../../../core/domain/entities/user_data/word_card.dart';
import '../../../../injection.dart';
import '../../../../services/query_helpers.dart';
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
import '../../../word_definition/bloc/word_interaction_bloc.dart';
import '../../../word_definition/screens/widgets/component_widget.dart';
import '../../../word_definition/screens/widgets/definition_header.dart';
import '../../../word_definition/screens/widgets/definition_sliver_app_bar.dart';
import '../../../word_definition/screens/widgets/example_sentence_widget.dart';
import '../../../word_definition/screens/widgets/is_common_tag_and_jlpt.dart';
import '../../../word_definition/screens/widgets/section_header.dart';
import '../../../word_definition/screens/widgets/word_view_count_widget.dart';
import '../bloc/main_search_bloc.dart';

part 'gen_ui_definition_screen.data.dart';
part 'gen_ui_definition_screen.sections.dart';
part 'gen_ui_definition_screen.streaming.dart';
part 'gen_ui_definition_screen.view_record.dart';

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

  /// Interaction bloc for view recording. Provided by the route, captured at
  /// init so the dispose fallback can dispatch without touching [context].
  late final WordInteractionBloc _interactionBloc;

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

  // Guard so the base-form view/history is recorded exactly once.
  bool _viewRecorded = false;

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

  /// setState entry point for the state extensions in this library.
  /// Extensions cannot use the protected [setState] directly.
  void _update(void Function() fn) {
    if (!mounted) return;
    setState(fn);
  }

  String get currentJapaneseWord => widget.args.query.trim();

  @override
  void initState() {
    super.initState();
    _interactionBloc = context.read<WordInteractionBloc>();
    _resolveBlocData();
    // Watch the local base immediately so the counter paints without waiting
    // for the LLM lane; the bloc re-watches the lemma once it lands.
    _interactionBloc.add(WatchWordInteraction(canonicalBaseForm(
      query: currentJapaneseWord,
      jishoDefinition: _jishoDefinition,
    )));
    _attachDataPrefetch();
    _startStreaming();
  }

  @override
  void dispose() {
    // Fallback when the LLM lane never completed: record under the local
    // base so the visit is still counted instead of silently dropped.
    _recordBaseView(null);
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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          DefinitionSliverAppBar(
            scrollController: _scrollController,
            title: _effectiveHeadword,
            tags: _hasTagData
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
            header: BlocBuilder<WordInteractionBloc, WordInteractionState>(
              buildWhen: (previous, current) =>
                  previous.word != current.word ||
                  previous.viewCount != current.viewCount,
              builder: (context, interactionState) => DefinitionHeader(
                pitchSection: _buildPitchAccentSection(),
                word: _effectiveHeadword,
                hanVietLine: _effectiveHanViet.isNotEmpty
                    ? _effectiveHanViet.join(' ').toUpperCase()
                    : null,
                picture: _descriptivePicture,
                pictureHeight: 96,
                pictureWidth: 96,
                pictureAlignment: Alignment.bottomCenter,
                trailing: WordViewCountWidget(
                  viewCounts: interactionState.viewCount,
                  margin: const EdgeInsets.only(left: 6),
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
                  AiGrammarBreakdownCard(
                    grammarAnalysis: _grammarAnalysis,
                    isLoading: _wordInfoPending,
                    onAskAiTutor: () {
                      context.push(
                        AppRoutesPath.aiChat,
                        extra: AiChatScreenArgs(
                          word: _effectiveHeadword,
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
                  AiTutorCard(
                    tutorComment: _aiTutorComment,
                    isLoading: _wordInfoPending,
                    errorMessage:
                        _errorMessage == 'missing_key' ? null : _errorMessage,
                  ),
                  AiMemoryTipCard(
                    memoryTip: _memoryTip,
                    isLoading: _wordInfoPending,
                  ),
                  SectionHeader(
                      title: isVn ? 'Giải thích AI' : 'AI Explanation'),
                  const SizedBox(height: 8),
                  _buildAiBodyContent(isVn),
                  divider,
                  SectionHeader(title: isVn ? 'Ví dụ' : 'Examples'),
                  _buildExamplesSection(isVn),
                  divider,
                  SectionHeader(title: isVn ? 'Thành phần' : 'Components'),
                  ComponentWidget(kanjiComponent: _kanjiListFuture),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
