import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

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
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late JishoDefinition jishoDefinition;
  late VietnameseDefinition vnDefinition;
  late String currentJapaneseWord;
  bool _historyRecorded = false;
  PreloadedImage? _descriptivePicture;
  String? _aiTutorComment;

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
      if (!mounted || info == null || info['found'] != true) return;
      setState(() {
        final comment = info['tutorComment']?.toString().trim() ?? '';
        if (comment.isNotEmpty) _aiTutorComment = comment;
      });
    });
    prefetch.image.then((picture) {
      if (!mounted || picture == null) return;
      setState(() => _descriptivePicture = picture);
    });
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
    return BlocBuilder<WordInteractionBloc, WordInteractionState>(
      builder: (context, interactionState) {
        return Scaffold(
          appBar: AppBar(
            title: widget.args.jishoDefinition != null
                ? IsCommonTagsAndJlptWidget(
                    isCommon: jishoDefinition.isCommon,
                    tags: jishoDefinition.tags,
                    jlpt: jishoDefinition.jlpt,
                  )
                : BlocConsumer<MainSearchBloc, MainSearchState>(
                    listener: (context, state) {
                      if (state is MainSearchJishoLoadedState) {
                        jishoDefinition = state.data.getSpecificJishoDefinition(
                                japaneseWord: currentJapaneseWord) ??
                            JishoDefinition(slug: '');
                        _recordViewAndHistory();
                      }
                    },
                    builder: (context, state) {
                      final jishoDef = state.data.getSpecificJishoDefinition(
                          japaneseWord: currentJapaneseWord);
                      final isCommon = jishoDef?.isCommon ?? false;
                      final tags = jishoDef?.tags ?? [];
                      final jlpt = jishoDef?.jlpt ?? [];

                      return IsCommonTagsAndJlptWidget(
                        isCommon: isCommon,
                        tags: tags,
                        jlpt: jlpt,
                      );
                    },
                  ),
            actions: [
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
                padding: const EdgeInsets.only(left: 20, right: 20),
                icon: interactionState.isInReview
                    ? const Icon(Icons.alarm_on_rounded, color: Colors.white)
                    : const Icon(Icons.alarm_add),
                onPressed: () {
                  context
                      .read<WordInteractionBloc>()
                      .add(ToggleWordReviewEvent(_createWordCard()));
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 10),
                FutureBuilder<List<Widget>>(
                  future: pitchAccent,
                  builder: (context, snapshot) {
                    if (snapshot.data == null ||
                        snapshot.data?.isEmpty == true) {
                      return Text(
                        jishoDefinition.reading ?? '',
                        style:
                            const TextStyle(fontSize: 15.0, color: Colors.grey),
                      );
                    }
                    return Row(children: snapshot.data!);
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            currentJapaneseWord,
                            style: const TextStyle(
                              fontSize: 45.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (getIt<SharedPref>().isAppInVietnamese &&
                              widget.args.hanViet?.isNotEmpty == true)
                            Text(
                              widget.args.hanViet.toString().toUpperCase(),
                              style: const TextStyle(fontSize: 22),
                            ),
                        ],
                      ),
                    ),
                    if (_descriptivePicture != null) ...[
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: _descriptivePicture!.provider,
                          height: 120,
                          width: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                                  ? child
                                  : const SizedBox(
                                      height: 120,
                                      width: 120,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFDB8C8A)),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                    WordViewCountWidget(
                      viewCounts: interactionState.viewCount,
                      margin: EdgeInsets.only(left: 8),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.data?.isEmpty ?? true) {
                        return ExampleSentenceWidget(
                          exampleSentence: KanjiHelper.getExampleSentence(
                            word: currentJapaneseWord,
                            context: context,
                            tableName: 'englishExampleDictionary',
                          ),
                        );
                      }
                      return ExampleSentenceWidget(
                        exampleSentence: exampleSentence,
                      );
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
                if (_aiTutorComment != null) ...[
                  const SizedBox(height: 12),
                  divider,
                  Row(
                    children: [
                      const Icon(Icons.record_voice_over,
                          color: Color(0xffDB8C8A), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        getIt<SharedPref>().isAppInVietnamese
                            ? 'Nhận xét từ AI Tutor'
                            : 'AI Tutor Notes',
                        style: const TextStyle(
                          color: Color(0xffDB8C8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDB8C8A).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _aiTutorComment!,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
