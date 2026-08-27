import 'package:go_router/go_router.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/features/history/screens/saved_definition_screen.dart';

import '../../../../../common/widgets/custom_dialog.dart';
import '../../../../../config/app_routes.dart';
import '../../../../../injection.dart';
import '../../../../../models/vietnamese_definition.dart';
import '../../../../../core/data/datasources/shared_pref.dart';
import '../../features/main_search/domain/entities/jisho_definition.dart';
import '../../features/word_definition/screens/widgets/definition_tags.dart';

class CommonQueryTile extends StatefulWidget {
  final JishoDefinition? jishoDefinition;
  final VietnameseDefinition? vnDefinition;
  final Future<List<String>> hanViet;
  final bool loadingDefinition;

  const CommonQueryTile({
    super.key,
    required this.hanViet,
    this.vnDefinition,
    this.jishoDefinition,
    this.loadingDefinition = false,
  });

  @override
  State<CommonQueryTile> createState() => _CommonQueryTileState();
}

class _CommonQueryTileState extends State<CommonQueryTile> {
  String get word {
    if (widget.vnDefinition?.word.isNotEmpty == true) {
      return widget.vnDefinition!.word;
    } else if (widget.jishoDefinition?.word?.isNotEmpty == true) {
      return widget.jishoDefinition!.word!;
    } else {
      return widget.jishoDefinition?.slug ?? '';
    }
  }

  WordCard _createWordCard() {
    return WordCard(
      id: word,
      word: widget.jishoDefinition?.word ?? word,
      slug: widget.jishoDefinition?.slug ?? '',
      reading: widget.jishoDefinition?.reading ?? '',
      isCommon: widget.jishoDefinition?.isCommon == true ? 1 : 0,
      tags: widget.jishoDefinition?.tags ?? const [],
      jlpt: widget.jishoDefinition?.jlpt ?? const [],
      senses: widget.jishoDefinition?.senses ?? const [],
      vietnameseDefinition: widget.vnDefinition?.definition ?? '',
      addedAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Widget parseVnDefHtmlWidget(String htmlString) {
    var document = parse(htmlString);
    var listList = document.querySelectorAll('li');

    for (dom.Element list in listList) {
      if (list.attributes['class'] == 'nv_a') {
        return Text(
          list.text.length > 150 ? list.text.substring(0, 150) : list.text,
          style: const TextStyle(fontSize: 12),
        );
      }
    }
    return const SizedBox();
  }

  Widget getVnDefinitionSummary() {
    if (widget.vnDefinition?.definition == null) {
      return const SizedBox();
    } else {
      return parseVnDefHtmlWidget(widget.vnDefinition?.definition ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userRepo = getIt<UserDataRepository>();

    return StreamBuilder<List<WordCard>>(
      stream: userRepo.watchAllCards(),
      builder: (context, snapshot) {
        final allCards = snapshot.data ?? [];
        final existing = allCards.where((c) => c.id == word || c.word == word || c.slug == word).firstOrNull;
        final isFavorite = existing?.isFavorite ?? false;
        final isInReview = existing?.isInReview ?? false;

        return ListTile(
          contentPadding: const EdgeInsets.only(left: 16.0, right: 0.0),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.jishoDefinition?.reading != null)
                Text(
                  widget.jishoDefinition?.reading ?? '',
                  style: const TextStyle(fontSize: 13),
                ),
              Text(
                word,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (getIt<SharedPref>().isAppInVietnamese)
                FutureBuilder<List<String>>(
                  future: widget.hanViet,
                  builder: (context, snapshot) {
                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const SizedBox(height: 0);
                    }
                    return SelectableText(
                      snapshot.data.toString().toUpperCase(),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (widget.loadingDefinition)
                const SizedBox(
                  width: 5,
                  height: 5,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              else
                Row(
                  children: [
                    if (widget.jishoDefinition?.isCommon == true)
                      const Card(
                        color: Color(0xFF8ABC82),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Text(
                            'common word',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    Flexible(
                      child: DefinitionTags(
                        tags: widget.jishoDefinition?.tags ?? [],
                        color: const Color(0xFF909DC0),
                      ),
                    ),
                    Flexible(
                      child: DefinitionTags(
                        tags: widget.jishoDefinition?.jlpt ?? [],
                        color: const Color(0xFF909DC0),
                      ),
                    ),
                  ],
                ),
              if (widget.jishoDefinition?.senses != null &&
                  getIt<SharedPref>().isAppInEnglish)
                Text(
                  widget.jishoDefinition!.senses.isNotEmpty
                      ? widget.jishoDefinition!.senses[0].englishDefinitions.toString()
                      : '',
                  style: const TextStyle(fontSize: 13),
                ),
              if (getIt<SharedPref>().isAppInVietnamese)
                getVnDefinitionSummary(),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 45,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: isFavorite
                      ? const Icon(Icons.bookmark, color: Color(0xffff8882))
                      : const Icon(Icons.bookmark_border, color: Colors.grey),
                  onPressed: () {
                    userRepo.toggleFavorite(card: _createWordCard());
                  },
                ),
              ),
              SizedBox(
                width: 45,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: isInReview
                      ? const Icon(Icons.alarm_on, color: Color(0xffff8882))
                      : const Icon(Icons.alarm_add),
                  onPressed: () {
                    userRepo.toggleReviewEnrollment(card: _createWordCard());
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            context.pushNamed(
              AppRoutesPath.savedWordDefinition,
              extra: SavedDefinitionScreenArgs(
                hanViet: widget.hanViet,
                jishoDefinition: widget.jishoDefinition,
                vnDefinition: widget.vnDefinition,
                isInFavoriteList: isFavorite,
              ),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                word: word,
                message: 'Delete this word from history?',
              ),
            ).then((confirmed) {
              if (confirmed == true) {
                userRepo.removeHistory(word);
              }
            });
          },
        );
      },
    );
  }
}
