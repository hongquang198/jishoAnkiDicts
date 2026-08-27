import 'package:flutter/material.dart';

class DefinitionTags extends StatelessWidget {
  final List<String> tags;
  final Color color;
  const DefinitionTags({super.key, required this.tags, required this.color});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: tags.where((tag) => tag.isNotEmpty).map((tag) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Text(
            tag,
            style: TextStyle(
              color: theme.brightness == Brightness.dark
                  ? color.withValues(alpha: 0.95)
                  : color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
        );
      }).toList(),
    );
  }
}
