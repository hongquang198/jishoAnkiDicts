import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/common/widgets/common_query_tile.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/features/history/bloc/history_bloc.dart';
import 'package:jisho_anki/injection.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/models/vietnamese_definition.dart';
import 'package:jisho_anki/services/kanji_helper.dart';
import 'package:jisho_anki/utils/constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HistoryBloc>()..add(const LoadHistory()),
      child: const _HistoryScreenView(),
    );
  }
}

class _HistoryScreenView extends StatefulWidget {
  const _HistoryScreenView();

  @override
  State<_HistoryScreenView> createState() => _HistoryScreenViewState();
}

class _HistoryScreenViewState extends State<_HistoryScreenView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  Future<VietnameseDefinition?> _getVietnameseDefinition(String word) async {
    try {
      final vnDefinition = await KanjiHelper.getVnDefinition(word: word);
      if (vnDefinition.isNotEmpty) return vnDefinition.first;
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
                  hintText: 'Search history...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  context.read<HistoryBloc>().add(SearchHistory(query));
                },
              )
            : Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(color: Constants.appBarTextColor),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  context.read<HistoryBloc>().add(const SearchHistory(''));
                  _isSearching = false;
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear all lookup history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ).then((confirmed) {
                if (confirmed == true && context.mounted) {
                  context.read<HistoryBloc>().add(const ClearAllHistory());
                }
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryLoaded) {
            final history = state.filteredHistory;
            if (history.isEmpty) {
              return Center(
                child: Text(
                  state.searchQuery.isNotEmpty
                      ? 'No history matches found.'
                      : 'No lookup history yet.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(8),
              separatorBuilder: (context, index) => const Divider(thickness: 0.4),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final card = history[index];
                return _buildHistoryTile(card);
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHistoryTile(WordCard card) {
    if (card.vietnameseDefinition.isNotEmpty) {
      return CommonQueryTile(
        hanViet: KanjiHelper.getHanvietReading(word: card.japaneseWord),
        vnDefinition: VietnameseDefinition(
          word: card.japaneseWord,
          definition: card.vietnameseDefinition,
        ),
        jishoDefinition: card.toJishoDefinition,
      );
    }

    return FutureBuilder<VietnameseDefinition?>(
      future: _getVietnameseDefinition(card.japaneseWord),
      builder: (context, snapshot) {
        return CommonQueryTile(
          hanViet: KanjiHelper.getHanvietReading(word: card.japaneseWord),
          vnDefinition: snapshot.data,
          jishoDefinition: card.toJishoDefinition,
        );
      },
    );
  }
}
