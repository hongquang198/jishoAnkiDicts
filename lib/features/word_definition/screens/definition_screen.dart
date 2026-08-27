import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

import '../../../core/data/datasources/shared_pref.dart';
import '../../../core/domain/entities/user_data/word_card.dart';
import '../../../core/domain/repositories/user_data_repository.dart';
import '../../../injection.dart';
import '../../../models/example_sentence.dart';
import '../../../models/kanji.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
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
import 'widgets/definition_widget.dart';
import 'widgets/example_sentence_widget.dart';
import 'widgets/is_common_tag_and_jlpt.dart';
import 'widgets/word_view_count_widget.dart';

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
            final word = args.vnDefinition?.word.isNotEmpty == true
                ? args.vnDefinition!.word
                : (args.jishoDefinition?.japaneseWord ??
                    args.jishoDefinition?.slug ??
                    '');
            return getIt<WordInteractionBloc>()
              ..add(WatchWordInteraction(word));
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

  @override
  void initState() {
    super.initState();
    jishoDefinition = widget.args.jishoDefinition ?? JishoDefinition(slug: '');
    vnDefinition = widget.args.vnDefinition ?? VietnameseDefinition();
    currentJapaneseWord = vnDefinition.word;
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.word ?? '';
    }
    if (currentJapaneseWord.isEmpty) {
      currentJapaneseWord = jishoDefinition.slug;
    }

    if (widget.args.jishoDefinition != null) {
      _recordViewAndHistory();
    }

    _attachDataPrefetch();

    pitchAccent = KanjiHelper.getPitchAccent(
      word: jishoDefinition.word,
      slug: jishoDefinition.slug,
      reading: jishoDefinition.reading,
      context: context,
    );

    kanjiList = KanjiHelper.getKanjiComponent(word: currentJapaneseWord);

    try {
      final lang = getIt<SharedPref>().prefs.getString('language');
      if (lang?.contains('English') == true) {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'englishExampleDictionary');
      } else if (lang == 'Tiếng Việt') {
        exampleSentence = KanjiHelper.getExampleSentence(
            word: currentJapaneseWord,
            context: context,
            tableName: 'exampleDictionary');
      }
    } catch (e) {
      log('Error getting example sentence $e');
    }
  }

  void _attachDataPrefetch() {
    final query = currentJapaneseWord;
    final cache = getIt<GenUiDataPrefetchCache>();
    var prefetch = cache.get(query);
    if (prefetch == null) {
      final fresh = startDefaultDataPrefetch(
        query: query,
        jishoDefinition: jishoDefinition,
      );
      cache.warm(query, start: () => fresh);
      prefetch = fresh;
    }

    prefetch.wordInfo.then((info) {
      if (!mounted) return;
      setState(() {
        _isAiLoading = false;
        if (info != null && info['found'] == true) {
          final comment = info['tutorComment']?.toString().trim() ?? '';
          if (comment.isNotEmpty) _aiTutorComment = comment;
          final memoryTip = info['memoryTip']?.toString().trim() ?? '';
          if (memoryTip.isNotEmpty) _aiMemoryTip = memoryTip;
          final grammar = info['grammarAnalysis']?.toString().trim() ?? '';
          if (grammar.isNotEmpty) _aiGrammarAnalysis = grammar;
        }
      });
    });
    prefetch.image.then((picture) {
      if (!mounted || picture == null) return;
      setState(() => _descriptivePicture = picture);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  WordCard _createWordCard() {
    return WordCard(
      id: currentJapaneseWord,
      word: jishoDefinition.word ?? currentJapaneseWord,
      slug: jishoDefinition.slug,
      reading: jishoDefinition.reading ?? '',
      isCommon: jishoDefinition.isCommon ? 1 : 0,
      tags: jishoDefinition.tags,
      jlpt: jishoDefinition.jlpt,
      senses: jishoDefinition.senses,
      vietnameseDefinition: vnDefinition.definition,
      addedAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  void _recordViewAndHistory() {
    if (_historyRecorded || currentJapaneseWord.isEmpty) return;
    _historyRecorded = true;
    final card = _createWordCard();
    getIt<UserDataRepository>().recordWordView(currentJapaneseWord);
    getIt<UserDataRepository>().addHistory(card);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool isSplitMode = screenHeight < 650;

    return BlocBuilder<WordInteractionBloc, WordInteractionState>(
      builder: (context, interactionState) {
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

                        // 4. Linearly interpolate the width based on scroll progress
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
                        child: widget.args.jishoDefinition != null
                            ? IsCommonTagsAndJlptWidget(
                                isCommon: jishoDefinition.isCommon,
                                tags: jishoDefinition.tags,
                                jlpt: jishoDefinition.jlpt,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      final offset = _scrollController.hasClients
                          ? _scrollController.offset
                          : 0.0;
                      final double maxScroll = 100.0;
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding:
                        EdgeInsets.fromLTRB(12, isSplitMode ? 50 : 98, 12, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FutureBuilder<List<Widget>>(
                                future: pitchAccent,
                                builder: (context, snapshot) {
                                  if (snapshot.data == null ||
                                      snapshot.data?.isEmpty == true) {
                                    return Text(
                                      jishoDefinition.reading ?? '',
                                      style: const TextStyle(
                                          fontSize: 14.0, color: Colors.grey),
                                    );
                                  }
                                  return Row(children: snapshot.data!);
                                },
                              ),
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
                              if (getIt<SharedPref>().isAppInVietnamese &&
                                  widget.args.hanViet?.isNotEmpty == true)
                                Text(
                                  widget.args.hanViet.toString().toUpperCase(),
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
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image(
                                image: _descriptivePicture!.provider,
                                height: 72,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                                loadingBuilder: (context, child, progress) =>
                                    progress == null
                                        ? child
                                        : const SizedBox(
                                            height: 72,
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
                        WordViewCountWidget(
                          viewCounts: interactionState.viewCount,
                          margin: const EdgeInsets.only(left: 6),
                        ),
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
                      DefinitionWidget(
                        senses: jishoDefinition.senses,
                        vietnameseDefinition: vnDefinition.definition,
                      ),
                      divider,
                      const Text(
                        'Examples',
                        style: TextStyle(
                          color: Color(0xffDB8C8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      FutureBuilder<List<ExampleSentence>>(
                        future: exampleSentence,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ExampleSentenceWidget(
                                exampleSentence: exampleSentence);
                          } else {
                            return const SizedBox();
                          }
                        },
                      ),
                      divider,
                      const Text(
                        'Components',
                        style: TextStyle(
                          color: Color(0xffDB8C8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      ComponentWidget(kanjiComponent: kanjiList),
                      const SizedBox(height: 12),
                      divider,
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.psychology,
                              color: Color(0xffDB8C8A), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            getIt<SharedPref>().isAppInVietnamese
                                ? 'Trợ lý AI'
                                : 'AI Tutor & Insights',
                            style: const TextStyle(
                              color: Color(0xffDB8C8A),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AiTutorCard(
                        tutorComment: _aiTutorComment,
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
                      AiMemoryTipCard(
                        memoryTip: _aiMemoryTip,
                        isLoading: _isAiLoading,
                      ),
                      AiGrammarBreakdownCard(
                        grammarAnalysis: _aiGrammarAnalysis,
                        isLoading: _isAiLoading,
                      ),
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
