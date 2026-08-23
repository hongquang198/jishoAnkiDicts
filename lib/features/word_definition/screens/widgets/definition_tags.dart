import 'package:flutter/material.dart';

class DefinitionTags extends StatelessWidget {
  final List<String> tags;
  final Color color;
  const DefinitionTags({super.key, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    if (tags.isNotEmpty) {
      for (int i = 0; i < tags.length;) {
        return tags[i].isNotEmpty
            ? Card(
                margin: const EdgeInsets.only(
                  left: 4.0,
                  top: 3.0,
                  bottom: 3.0,
                ),
                color: color,
                child: Text(
                  ' ${tags[i]} ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.0,
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
