import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/common/widgets/common_query_tile.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/favorite_words/bloc/favorite_bloc.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/models/localized_gloss.dart';
import 'package:jisho_anki/services/kanji_helper.dart';
import 'package:jisho_anki/utils/constants.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<FavoriteBloc>()..add(const LoadFavorites()),
      child: const _FavoriteScreenView(),
    );
  }
}

class _FavoriteScreenView extends StatefulWidget {
  const _FavoriteScreenView();

  @override
  State<_FavoriteScreenView> createState() => _FavoriteScreenViewState();
}

class _FavoriteScreenViewState extends State<_FavoriteScreenView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<LocalizedGloss?> _getLocalizedGloss(String word) async {
    try {
      final localizedGloss = await KanjiHelper.getLocalizedGloss(word: word);
      if (localizedGloss.isNotEmpty) return localizedGloss.first;
    } catch (e) {
      log('No VN definition found: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search favorites...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<FavoriteBloc>().add(SearchFavorites(query));
                },
              )
            : Text(
                AppLocalizations.of(context)!.favorite,
                style: TextStyle(color: Constants.appBarTextColor),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<FavoriteBloc>().add(const SearchFavorites(''));
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is FavoriteLoaded) {
            final favorites = state.filteredFavorites;
            if (favorites.isEmpty) {
              return Center(
                child: Text(
                  state.searchQuery.isNotEmpty
                      ? 'No matches found.'
                      : 'No favorite words saved yet.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              separatorBuilder: (context, index) => const Divider(thickness: 0.4),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final card = favorites[index];
                return _buildFavoriteTile(card);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFavoriteTile(WordCard card) {
    if (card.localizedGloss.isNotEmpty) {
      return CommonQueryTile(
        hanViet: KanjiHelper.getHanvietReading(word: card.headword),
        localizedGloss: LocalizedGloss(
          headword: card.headword,
          gloss: card.localizedGloss,
        ),
        jishoDefinition: card.toJishoDefinition,
      );
    }

    return FutureBuilder<LocalizedGloss?>(
      future: _getLocalizedGloss(card.headword),
      builder: (context, snapshot) {
        return CommonQueryTile(
          hanViet: KanjiHelper.getHanvietReading(word: card.headword),
          localizedGloss: snapshot.data,
          jishoDefinition: card.toJishoDefinition,
        );
      },
    );
  }
}
