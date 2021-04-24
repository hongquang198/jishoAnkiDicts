import 'package:JapaneseOCR/utils/offlineListType.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BookmarkIcon extends StatefulWidget {
  bool isInFavoriteList;
  final Function addToOfflineList;
  final Function removeFromOfflineList;
  BookmarkIcon(
      {this.isInFavoriteList,
      this.addToOfflineList,
      this.removeFromOfflineList});
  @override
  _BookmarkIconState createState() => _BookmarkIconState();
}

class _BookmarkIconState extends State<BookmarkIcon> {
  //TODO

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        child: widget.isInFavoriteList
            ? Icon(Icons.bookmark, color: Color(0xffff8882))
            : Icon(Icons.bookmark, color: Colors.grey),
        onPressed: () {
          if (widget.isInFavoriteList == false) {
            setState(() {
              widget.addToOfflineList(OfflineListType.favorite);
              widget.isInFavoriteList = true;
            });
          } else
            setState(() {
              widget.removeFromOfflineList();
              widget.isInFavoriteList = false;
            });
        },
      ),
    );
  }
}
