import '/models/offlineWordRecord.dart';
import 'package:flutter/material.dart';

class CardInfoScreen extends StatefulWidget {
  final OfflineWordRecord offlineWordRecord;
  CardInfoScreen({required this.offlineWordRecord});

  @override
  _CardInfoScreenState createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen> {
  late Duration duration;

  @override
  void initState() {
    duration = Duration(milliseconds: widget.offlineWordRecord.interval);
    super.initState();
  }

  Text getInterval() {
    if (widget.offlineWordRecord.interval <= 10 * 60 * 1000) {
      return Text(
          '${Duration(milliseconds: widget.offlineWordRecord.interval).inMinutes}min');
    } else if (widget.offlineWordRecord.interval <= 31 * 24 * 60 * 60 * 1000) {
      return Text(
          '${Duration(milliseconds: widget.offlineWordRecord.interval).inDays}day');
    } else if (widget.offlineWordRecord.interval <= 365 * 24 * 60 * 60 * 1000) {
      return Text(
          '${(Duration(milliseconds: widget.offlineWordRecord.interval).inDays / 31).toStringAsFixed(1)}month');
    }
    return Text(
        '${(Duration(milliseconds: widget.offlineWordRecord.interval).inDays / 365).toStringAsFixed(1)}year');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Word: ${widget.offlineWordRecord.word}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Added: '),
              Text(
                  '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.added)}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('First Review'),
              Text(
                  '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.firstReview!)}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Latest review'),
              Text(
                  '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.lastReview!)}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due'),
              Text(
                  '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.due!)}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Interval'),
              getInterval(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Ease'), Text('${widget.offlineWordRecord.ease}')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reviews'),
              Text('${widget.offlineWordRecord.reviews}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lapses'),
              Text('${widget.offlineWordRecord.lapses}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Average Time'),
              Text('${widget.offlineWordRecord.averageTimeMinute}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Time'),
              Text('${widget.offlineWordRecord.totalTimeMinute}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Card Type'),
              Text('${widget.offlineWordRecord.cardType}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Note type'),
              Text('${widget.offlineWordRecord.noteType}')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('Deck'), Text('${widget.offlineWordRecord.deck}')],
          ),
        ],
      ),
    );
  }
}
