import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/common/widgets/custom_dialog.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/core/domain/entities/user_data/srs_stage.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/ai_chat/screens/ai_chat_screen.dart';
import 'package:jisho_anki/features/card_info/screens/card_info_screen.dart';
import 'package:jisho_anki/features/review/bloc/review_bloc.dart';
import 'package:jisho_anki/features/review/screens/widgets/answer_button.dart';
import 'package:jisho_anki/features/review/screens/widgets/review_info.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/component_widget.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/definition_tags.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/definition_widget.dart';
import 'package:jisho_anki/features/word_definition/screens/widgets/example_sentence_widget.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/models/example_sentence.dart';
import 'package:jisho_anki/models/kanji.dart';
import 'package:jisho_anki/models/vietnamese_definition.dart';
import 'package:jisho_anki/services/kanji_helper.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:jisho_anki/services/srs_engine.dart';
import 'package:jisho_anki/config/app_routes.dart';
import 'package:jisho_anki/common/widgets/ai/ai_tutor_card.dart';
import 'package:jisho_anki/common/widgets/ai/ai_memory_tip_card.dart';
import 'package:jisho_anki/common/widgets/ai/ai_grammar_breakdown_card.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReviewBloc>()..add(const LoadReviewSession()),
      child: const _ReviewScreenView(),
    );
  }
}

class _ReviewScreenView extends StatefulWidget {
  const _ReviewScreenView();

  @override
  State<_ReviewScreenView> createState() => _ReviewScreenViewState();
}

class _ReviewScreenViewState extends State<_ReviewScreenView> {
  bool showAll = false;
  Future<List<Widget>>? pitchAccent;
  Future<List<Kanji>>? kanjiComponent;
  Future<List<String>>? hanViet;
  Future<List<ExampleSentence>>? enExampleSentence;
  Future<List<ExampleSentence>>? vnExampleSentence;
  String? _aiTutorComment;
  String? _aiMemoryTip;
  String? _aiGrammarAnalysis;
  bool _isAiLoading = false;

  Divider get divider =>
      Divider(thickness: 0.4, color: Theme.of(context).dividerColor);

  void _loadAdditionalInfo(WordCard card) {
    hanViet = KanjiHelper.getHanvietReading(word: card.word);
    pitchAccent = KanjiHelper.getPitchAccent(
      word: card.word,
      slug: card.slug,
      reading: card.reading,
      context: context,
    );
    enExampleSentence = KanjiHelper.getExampleSentence(
      word: card.word,
      context: context,
      tableName: 'englishExampleDictionary',
    );
    vnExampleSentence = KanjiHelper.getExampleSentence(
      word: card.word,
      context: context,
      tableName: 'exampleDictionary',
    );

    // If AI insights are already saved in the card from previous interaction/DB, use them without calling LLM!
    if (card.aiTutorComment != null || card.aiMemoryTip != null) {
      setState(() {
        _aiTutorComment = card.aiTutorComment;
        _aiMemoryTip = card.aiMemoryTip;
        _aiGrammarAnalysis = null;
        _isAiLoading = false;
      });
      return;
    }

    setState(() {
      _aiTutorComment = null;
      _aiMemoryTip = null;
      _aiGrammarAnalysis = null;
      _isAiLoading = true;
    });

    getIt<LlmService>().fetchWordInfo(card.word).then((info) {
      if (!mounted) return;
      setState(() {
        _isAiLoading = false;
        if (info != null && info['found'] == true) {
          _aiTutorComment = info['tutorComment']?.toString();
          _aiMemoryTip = info['memoryTip']?.toString();
          _aiGrammarAnalysis = info['grammarAnalysis']?.toString();
        }
      });
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _isAiLoading = false);
    });
  }

  Future<VietnameseDefinition?> _getVietnameseDefinition(String word) async {
    try {
      final vnList = await KanjiHelper.getVnDefinition(word: word);
      if (vnList.isNotEmpty) return vnList.first;
    } catch (e) {
      log('No VN definition found $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSessionLoaded && state.currentCard != null) {
          _loadAdditionalInfo(state.currentCard!);
          setState(() {
            showAll = false;
          });
        }
      },
      builder: (context, state) {
        if (state is ReviewLoading) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.review)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReviewSessionCompleted) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.review)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.reviewComplete,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (state.totalReviewed > 0) ...[
                    const SizedBox(height: 8),
                    Text('Completed ${state.totalReviewed} cards in this session!'),
                  ],
                ],
              ),
            ),
          );
        }

        if (state is ReviewSessionLoaded && state.currentCard != null) {
          final card = state.currentCard!;
          if (pitchAccent == null) {
            _loadAdditionalInfo(card);
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.review),
              actions: [
                if (state.undoStack.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      context.read<ReviewBloc>().add(const UndoLastReview());
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => CustomDialog(
                        word: card.japaneseWord,
                        message: 'Remove this card from review deck?',
                      ),
                    ).then((confirmed) {
                      if (context.mounted) {
                        context.read<ReviewBloc>().add(const DeleteCurrentCard());
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => CardInfoScreen(card: card),
                      ),
                    );
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Container(
                  height: 28,
                  color: const Color(0xFFF7E7E6),
                  alignment: Alignment.center,
                  child: ReviewInfo(
                    newCardsCount: state.newCardsCount,
                    learningCardsCount: state.learningCardsCount,
                    dueCardsCount: state.dueCardsCount,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      const SizedBox(height: 10),
                      if (showAll && pitchAccent != null)
                        FutureBuilder<List<Widget>>(
                          future: pitchAccent,
                          builder: (context, snapshot) {
                            if (snapshot.data == null || snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  card.reading,
                                  style: const TextStyle(fontSize: 15.0, color: Colors.grey),
                                ),
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: snapshot.data!,
                            );
                          },
                        ),
                      Center(
                        child: Text(
                          card.japaneseWord,
                          style: const TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (showAll && getIt<SharedPref>().isAppInVietnamese && hanViet != null)
                        FutureBuilder<List<String>>(
                          future: hanViet,
                          builder: (context, snapshot) {
                            if (snapshot.data == null || snapshot.data!.isEmpty) return const SizedBox();
                            return Center(
                              child: Text(
                                snapshot.data.toString().toUpperCase(),
                                style: const TextStyle(fontSize: 22),
                              ),
                            );
                          },
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (card.isCommon == 1)
                            const Card(
                              color: Color(0xFF8ABC82),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text(
                                  'common word',
                                  style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          Flexible(child: DefinitionTags(tags: card.tags, color: const Color(0xFF909DC0))),
                          Flexible(child: DefinitionTags(tags: card.jlpt, color: const Color(0xFF909DC0))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (showAll) _buildDefinitionWidget(card),
                      if (showAll) divider,
                      if (showAll)
                        const Center(
                          child: Text(
                            'Examples',
                            style: TextStyle(color: Color(0xffDB8C8A), fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                      if (showAll && vnExampleSentence != null && enExampleSentence != null)
                        FutureBuilder<List<ExampleSentence>>(
                          future: vnExampleSentence,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                              if (snapshot.data!.isEmpty) {
                                return ExampleSentenceWidget(exampleSentence: enExampleSentence!);
                              }
                              return ExampleSentenceWidget(exampleSentence: vnExampleSentence!);
                            }
                            return const SizedBox();
                          },
                        ),
                      if (showAll) divider,
                      if (showAll)
                        const Center(
                          child: Text(
                            'Components',
                            style: TextStyle(color: Color(0xffDB8C8A), fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                      if (showAll)
                        ComponentWidget(
                          kanjiComponent: KanjiHelper.getKanjiComponent(word: card.japaneseWord),
                        ),
                      if (showAll) ...[
                        divider,
                        const Center(
                          child: Text(
                            'AI Tutor & Insights',
                            style: TextStyle(color: Color(0xffDB8C8A), fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AiTutorCard(
                          tutorComment: _aiTutorComment,
                          isLoading: _isAiLoading,
                        ),
                        AiMemoryTipCard(
                          memoryTip: _aiMemoryTip,
                          isLoading: _isAiLoading,
                        ),
                        AiGrammarBreakdownCard(
                          grammarAnalysis: _aiGrammarAnalysis,
                          isLoading: _isAiLoading,
                          onAskAiTutor: () {
                            context.push(
                              AppRoutesPath.aiChat,
                              extra: AiChatScreenArgs(
                                word: card.word,
                                reading: card.reading,
                                definition: card.vietnameseDefinition,
                                existingTutorComment: _aiTutorComment,
                                existingMemoryTip: _aiMemoryTip,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (!showAll)
                  InkWell(
                    onTap: () {
                      setState(() {
                        showAll = true;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      color: const Color(0xFF385499),
                      alignment: Alignment.center,
                      child: const Text(
                        'Show Answer',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      SrsAnswerButton(
                        card: card,
                        rating: SrsRating.again,
                        srsEngine: getIt<SrsEngine>(),
                        onTap: () {
                          context.read<ReviewBloc>().add(const RateCurrentCard(rating: SrsRating.again));
                        },
                      ),
                      SrsAnswerButton(
                        card: card,
                        rating: SrsRating.hard,
                        srsEngine: getIt<SrsEngine>(),
                        onTap: () {
                          context.read<ReviewBloc>().add(const RateCurrentCard(rating: SrsRating.hard));
                        },
                      ),
                      SrsAnswerButton(
                        card: card,
                        rating: SrsRating.good,
                        srsEngine: getIt<SrsEngine>(),
                        onTap: () {
                          context.read<ReviewBloc>().add(const RateCurrentCard(rating: SrsRating.good));
                        },
                      ),
                      SrsAnswerButton(
                        card: card,
                        rating: SrsRating.easy,
                        srsEngine: getIt<SrsEngine>(),
                        onTap: () {
                          context.read<ReviewBloc>().add(const RateCurrentCard(rating: SrsRating.easy));
                        },
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.review)),
          body: Center(
            child: Text(AppLocalizations.of(context)!.reviewComplete),
          ),
        );
      },
    );
  }

  Widget _buildDefinitionWidget(WordCard card) {
    if (card.vietnameseDefinition.isNotEmpty) {
      return DefinitionWidget(
        senses: card.senses,
        vietnameseDefinition: card.vietnameseDefinition,
      );
    }
    return FutureBuilder<VietnameseDefinition?>(
      future: _getVietnameseDefinition(card.japaneseWord),
      builder: (context, snapshot) {
        return DefinitionWidget(
          senses: card.senses,
          vietnameseDefinition: snapshot.data?.definition,
        );
      },
    );
  }
}
