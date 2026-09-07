import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../core/data/datasources/shared_pref.dart';
import '../../../core/domain/entities/user_data/word_card.dart';
import '../../../injection.dart';
import '../../../models/example_sentence.dart';
import '../../../models/kanji.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
import '../../../services/query_helpers.dart';
import '../../../services/llm/gen_ui_data_prefetch.dart';
import '../../../services/preloaded_image.dart';
import '../../../common/widgets/ai/ai_tutor_card.dart';
import '../../../common/widgets/ai/ai_memory_tip_card.dart';
import '../../../common/widgets/ai/ai_grammar_breakdown_card.dart';
import '../../../config/app_routes.dart';
import '../../ai_chat/screens/ai_chat_screen.dart';
import '../../main_search/domain/entities/jisho_definition.dart';
import '../../main_search/presentation/bloc/main_search_bloc.dart';
import '../../main_search/presentation/screens/gen_ui_definition_screen.dart';
import '../bloc/word_interaction_bloc.dart';
import 'widgets/component_widget.dart';
import 'widgets/definition_header.dart';
import 'widgets/definition_sliver_app_bar.dart';
import 'widgets/definition_widget.dart';
import 'widgets/example_sentence_widget.dart';
import 'widgets/is_common_tag_and_jlpt.dart';
import 'widgets/pitch_accent_line.dart';
import 'widgets/section_header.dart';
import 'widgets/word_view_count_widget.dart';

part 'definition_screen.data.dart';
part 'definition_screen.view_record.dart';

class DefinitionScreenArgs {
  MainSearchBloc mainSearchBloc;
  final List<String>? hanViet;
  final VietnameseDefinition? vnDefinition;
  final JishoDefinition? jishoDefinition;
  final bool isInFavoriteList;
  final bool isOfflineList;
  DefinitionScreenArgs({
    required this.mainSearchBloc,
    this.hanViet,
    this.vnDefinition,
    this.jishoDefinition,
    required this.isInFavoriteList,
    this.isOfflineList = false,
  });
}

class DefinitionScreen extends StatefulWidget {
  final DefinitionScreenArgs args;
  const DefinitionScreen({
    super.key,
    required this.args,
  });

  static Widget provider({
    required DefinitionScreenArgs args,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: args.mainSearchBloc),
        BlocProvider(
          create: (context) {
            // Watch the local base form immediately so the counter paints
            // without flashing the inflected surface; the bloc re-watches
            // with the LLM lemma once its lane completes.
            final vnWord = args.vnDefinition?.word ?? '';
            final query = vnWord.isNotEmpty
                ? vnWord
                : (args.jishoDefinition?.japaneseWord ??
                    args.jishoDefinition?.slug ??
                    '');
            return getIt<WordInteractionBloc>()
              ..add(WatchWordInteraction(canonicalBaseForm(
                query: query,
                jishoDefinition: args.jishoDefinition,
                vnWord: vnWord,
              )));
          },
        ),
      ],
      child: DefinitionScreen(args: args),
    );
  }

  @override
  State<DefinitionScreen> createState() => _DefinitionScreenState();
}

class _DefinitionScreenState extends State<DefinitionScreen> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late JishoDefinition jishoDefinition;
  late VietnameseDefinition vnDefinition;
  late String currentJapaneseWord;
  bool _historyRecorded = false;
  PreloadedImage? _descriptivePicture;
  String? _aiTutorComment;
  String? _aiMemoryTip;
  String? _aiGrammarAnalysis;
  bool _isAiLoading = true;

  Divider get divider =>
      Divider(thickness: 0.4, color: Theme.of(context).dividerColor);

  /// setState entry point for the state extensions in this library.
  /// Extensions cannot use the protected [setState] directly.
  void _update(void Function() fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _resolveArgs();
    _attachDataPrefetch();
    _recordViewByBase();
    _loadLocalFutures();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVn = getIt<SharedPref>().isAppInVietnamese;
    return BlocBuilder<WordInteractionBloc, WordInteractionState>(
      builder: (context, interactionState) {
        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              DefinitionSliverAppBar(
                scrollController: _scrollController,
                title: currentJapaneseWord,
                tags: widget.args.jishoDefinition != null
                    ? IsCommonTagsAndJlptWidget(
                        isCommon: jishoDefinition.isCommon,
                        tags: jishoDefinition.tags,
                        jlpt: jishoDefinition.jlpt,
                      )
                    : const SizedBox.shrink(),
                actions: [
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      final offset = _scrollController.hasClients
                          ? _scrollController.offset
                          : 0.0;
                      const double maxScroll = 100.0;
                      final double progress =
                          (offset / maxScroll).clamp(0.0, 1.0);
                      return Opacity(
                        opacity: progress,
                        child: child,
                      );
                    },
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: WordViewCountWidget(
                          viewCounts: interactionState.viewCount,
                          onlyShowNumber: true,
                          margin: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: interactionState.isFavorite
                            ? const Icon(Icons.bookmark, color: Colors.white)
                            : const Icon(Icons.bookmark_border),
                        onPressed: () {
                          context
                              .read<WordInteractionBloc>()
                              .add(ToggleWordFavoriteEvent(_createWordCard()));
                        },
                      ),
                      IconButton(
                        padding: const EdgeInsets.only(left: 4, right: 8),
                        icon: interactionState.isInReview
                            ? const Icon(Icons.alarm_on_rounded,
                                color: Colors.white)
                            : const Icon(Icons.alarm_add),
                        onPressed: () {
                          context
                              .read<WordInteractionBloc>()
                              .add(ToggleWordReviewEvent(_createWordCard()));
                        },
                      ),
                    ],
                  ),
                ],
                header: DefinitionHeader(
                  pitchSection: PitchAccentLine(
                    pitchAccent: pitchAccent,
                    fallbackReading: jishoDefinition.reading ?? '',
                  ),
                  word: currentJapaneseWord,
                  hanVietLine: isVn &&
                          widget.args.hanViet?.isNotEmpty == true
                      ? widget.args.hanViet.toString().toUpperCase()
                      : null,
                  picture: _descriptivePicture,
                  trailing: WordViewCountWidget(
                    viewCounts: interactionState.viewCount,
                    margin: const EdgeInsets.only(left: 6),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 2),
                      DefinitionWidget(
                        senses: jishoDefinition.senses,
                        vietnameseDefinition: vnDefinition.definition,
                      ),
                      divider,
                      const SectionHeader(title: 'Examples'),
                      ExampleSentenceWidget(exampleSentence: exampleSentence),
                      divider,
                      const SectionHeader(title: 'Components'),
                      ComponentWidget(kanjiComponent: kanjiList),
                      divider,
                      SectionHeader(
                        title: isVn ? 'Trợ lý AI' : 'AI Tutor & Insights',
                        icon: Icons.psychology,
                      ),
                      const SizedBox(height: 8),
                      AiGrammarBreakdownCard(
                        grammarAnalysis: _aiGrammarAnalysis,
                        isLoading: _isAiLoading,
                        onAskAiTutor: () {
                          context.push(
                            AppRoutesPath.aiChat,
                            extra: AiChatScreenArgs(
                              word: currentJapaneseWord,
                              reading: jishoDefinition.reading,
                              definition: vnDefinition.definition,
                              existingTutorComment: _aiTutorComment,
                              existingMemoryTip: _aiMemoryTip,
                            ),
                          );
                        },
                      ),
                      AiTutorCard(
                        tutorComment: _aiTutorComment,
                        isLoading: _isAiLoading,
                      ),
                      AiMemoryTipCard(
                        memoryTip: _aiMemoryTip,
                        isLoading: _isAiLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
