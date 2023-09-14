import 'package:flutter/material.dart';

class DefinitionTags extends StatelessWidget {
  final List<dynamic> tags;
  final Color color;
  DefinitionTags({required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    if (tags.length > 0) {
      for (int i = 0; i < tags.length;) {
        return tags[i] != null && tags[i].length > 0
            ? Card(
                color: color,
                child: Text(
                  tags[i] == null ? '' : tags[i].toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : SizedBox();
      }
    }
    return SizedBox();
  }
}
