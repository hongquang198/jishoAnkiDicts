import 'package:JapaneseOCR/models/offlineWordRecord.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CardInfoScreen extends StatefulWidget {
  final OfflineWordRecord offlineWordRecord;
  CardInfoScreen({@required this.offlineWordRecord});

  @override
  _CardInfoScreenState createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen> {
  Duration duration;

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
                  'Word: ${widget.offlineWordRecord.word ?? widget.offlineWordRecord.slug}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Added: '),
              widget.offlineWordRecord.added != null
                  ? Text(
                      '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.added)}')
                  : SizedBox(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('First Review'),
              widget.offlineWordRecord.firstReview != null
                  ? Text(
                      '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.firstReview)}')
                  : SizedBox(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Latest review'),
              widget.offlineWordRecord.lastReview != null
                  ? Text(
                      '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.lastReview)}')
                  : SizedBox(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Due'),
              widget.offlineWordRecord.due != null
                  ? Text(
                      '${DateTime.fromMillisecondsSinceEpoch(widget.offlineWordRecord.due)}')
                  : SizedBox(),
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
