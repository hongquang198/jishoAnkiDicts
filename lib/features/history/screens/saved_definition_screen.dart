import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../core/data/datasources/shared_pref.dart';
import '../../../core/domain/entities/user_data/word_card.dart';
import '../../../injection.dart';
import '../../../models/example_sentence.dart';
import '../../../models/kanji.dart';
import '../../../models/vietnamese_definition.dart';
import '../../../services/kanji_helper.dart';
import '../../main_search/domain/entities/jisho_definition.dart';
import '../../word_definition/bloc/word_interaction_bloc.dart';
import '../../word_definition/screens/widgets/component_widget.dart';
import '../../word_definition/screens/widgets/definition_widget.dart';
import '../../word_definition/screens/widgets/example_sentence_widget.dart';
import '../../word_definition/screens/widgets/is_common_tag_and_jlpt.dart';
import '../../word_definition/screens/widgets/word_view_count_widget.dart';

class SavedDefinitionScreenArgs {
  final Future<List<String>>? hanViet;
  final VietnameseDefinition? vnDefinition;
  final JishoDefinition? jishoDefinition;
  final bool isInFavoriteList;
  final bool isOfflineList;
  SavedDefinitionScreenArgs({
    this.hanViet,
    this.vnDefinition,
    this.jishoDefinition,
    required this.isInFavoriteList,
    this.isOfflineList = false,
  });
}

class SavedDefinitionScreen extends StatelessWidget {
  final SavedDefinitionScreenArgs args;
  const SavedDefinitionScreen({
    required this.args,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final word = args.vnDefinition?.word.isNotEmpty == true
        ? args.vnDefinition!.word
        : (args.jishoDefinition?.japaneseWord ?? args.jishoDefinition?.slug ?? '');

    return BlocProvider(
      create: (context) => getIt<WordInteractionBloc>()..add(WatchWordInteraction(word)),
      child: _SavedDefinitionScreenView(args: args),
    );
  }
}

class _SavedDefinitionScreenView extends StatefulWidget {
  final SavedDefinitionScreenArgs args;
  const _SavedDefinitionScreenView({required this.args});

  @override
  State<_SavedDefinitionScreenView> createState() => _SavedDefinitionScreenViewState();
}

class _SavedDefinitionScreenViewState extends State<_SavedDefinitionScreenView> {
  late Future<List<Widget>> pitchAccent;
  late Future<List<Kanji>> kanjiList;
  late Future<List<ExampleSentence>> exampleSentence;
  late JishoDefinition jishoDefinition;
  late VietnameseDefinition vnDefinition;
  late String currentJapaneseWord;

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WordInteractionBloc, WordInteractionState>(
      builder: (context, interactionState) {
        return Scaffold(
          appBar: AppBar(
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
                    if (snapshot.data == null) {
                      return Text(
                        jishoDefinition.reading ?? '',
                        style: const TextStyle(fontSize: 15.0, color: Colors.grey),
                      );
                    }
                    return Row(children: snapshot.data!);
                  },
                ),
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
                    WordViewCountWidget(viewCounts: interactionState.viewCount),
                  ],
                ),
                if (getIt<SharedPref>().isAppInVietnamese)
                  FutureBuilder<List<String>>(
                    future: widget.args.hanViet,
                    builder: (context, snapshot) {
                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const SizedBox();
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            snapshot.data.toString().toUpperCase(),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ],
                      );
                    },
                  ),
                if (widget.args.jishoDefinition != null)
                  IsCommonTagsAndJlptWidget(
                    isCommon: jishoDefinition.isCommon,
                    tags: jishoDefinition.tags,
                    jlpt: jishoDefinition.jlpt,
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
              ],
            ),
          ),
        );
      },
    );
  }
}
