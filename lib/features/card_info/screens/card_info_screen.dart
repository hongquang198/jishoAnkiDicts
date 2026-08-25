import 'package:flutter/material.dart';
import 'package:jisho_anki/core/domain/entities/user_data/word_card.dart';
import 'package:jisho_anki/models/offline_word_record.dart';

class CardInfoScreen extends StatelessWidget {
  final WordCard? card;
  final OfflineWordRecord? offlineWordRecord;

  const CardInfoScreen({
    super.key,
    this.card,
    this.offlineWordRecord,
  });

  String get word => card?.japaneseWord ?? offlineWordRecord?.japaneseWord ?? '';
  int get addedAt => card?.addedAt ?? offlineWordRecord?.added ?? 0;
  int? get firstReview => card?.srsData?.firstReviewedAt ?? offlineWordRecord?.firstReview;
  int? get lastReview => card?.srsData?.lastReviewedAt ?? offlineWordRecord?.lastReview;
  int get due => card?.srsData?.dueAt ?? offlineWordRecord?.due ?? 0;
  int get intervalMs => card?.srsData?.intervalMs ?? offlineWordRecord?.interval ?? 0;
  double get ease => card?.srsData?.easeFactor ?? offlineWordRecord?.ease ?? 2.5;
  int get reviews => card?.srsData?.reviews ?? offlineWordRecord?.reviews ?? 0;
  int get lapses => card?.srsData?.lapses ?? offlineWordRecord?.lapses ?? 0;
  String get stage => card?.srsData?.stage.name ?? offlineWordRecord?.cardType ?? 'New';
  String get deck => card?.deck ?? offlineWordRecord?.deck ?? 'default';

  String get intervalText {
    if (intervalMs <= 10 * 60 * 1000) {
      return '${(intervalMs / (60 * 1000)).round()}min';
    } else if (intervalMs <= 31 * 24 * 60 * 60 * 1000) {
      return '${(intervalMs / (24 * 60 * 60 * 1000)).round()}day';
    } else if (intervalMs <= 365 * 24 * 60 * 60 * 1000) {
      return '${(intervalMs / (30 * 24 * 60 * 60 * 1000)).toStringAsFixed(1)}month';
    }
    return '${(intervalMs / (365 * 24 * 60 * 60 * 1000)).toStringAsFixed(1)}year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildRow('Word', word),
            const Divider(),
            _buildRow('Deck', deck),
            const Divider(),
            _buildRow('Stage', stage),
            const Divider(),
            _buildRow('Added', addedAt > 0 ? DateTime.fromMillisecondsSinceEpoch(addedAt).toString().split('.')[0] : 'N/A'),
            const Divider(),
            _buildRow('First Review', firstReview != null ? DateTime.fromMillisecondsSinceEpoch(firstReview!).toString().split('.')[0] : 'N/A'),
            const Divider(),
            _buildRow('Latest Review', lastReview != null ? DateTime.fromMillisecondsSinceEpoch(lastReview!).toString().split('.')[0] : 'N/A'),
            const Divider(),
            _buildRow('Due', due > 0 ? DateTime.fromMillisecondsSinceEpoch(due).toString().split('.')[0] : 'N/A'),
            const Divider(),
            _buildRow('Interval', intervalText),
            const Divider(),
            _buildRow('Ease Factor', ease.toStringAsFixed(2)),
            const Divider(),
            _buildRow('Reviews', '$reviews'),
            const Divider(),
            _buildRow('Lapses', '$lapses'),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}
