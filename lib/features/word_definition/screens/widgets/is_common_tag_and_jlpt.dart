import 'package:flutter/material.dart';
import 'definition_tags.dart';

class IsCommonTagsAndJlptWidget extends StatelessWidget {
  const IsCommonTagsAndJlptWidget({
    super.key,
    required this.isCommon,
    required this.tags,
    required this.jlpt,
  });

  final bool isCommon;
  final List<String> tags;
  final List<String> jlpt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = isCommon || tags.isNotEmpty || jlpt.isNotEmpty;
    if (!hasContent) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (isCommon)
          DefinitionTags(
            tags: ['common'],
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF81C784)
                : const Color(0xFF2E7D32),
          ),
        if (tags.isNotEmpty)
          DefinitionTags(
            tags: tags,
            color: theme.colorScheme.secondary,
          ),
        if (jlpt.isNotEmpty)
          DefinitionTags(
            tags: jlpt,
            color: theme.colorScheme.tertiary,
          ),
      ],
    );
  }
}
