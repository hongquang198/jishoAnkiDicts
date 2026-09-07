import 'package:flutter/material.dart';

import '../../../../services/preloaded_image.dart';
import 'descriptive_picture.dart';

/// Expanded app-bar header shared by the dictionary detail screens.
///
/// Pure render widget: pitch section, headword, Sino-Vietnamese line,
/// descriptive picture, and an optional trailing (e.g. the view counter).
/// Both the classic and GenUI definition screens use it so the header layout
/// exists exactly once; callers supply already-resolved values.
class DefinitionHeader extends StatelessWidget {
  final Widget pitchSection;
  final String word;

  /// Pre-formatted Sino-Vietnamese line, or null to hide it.
  final String? hanVietLine;
  final PreloadedImage? picture;
  final double pictureHeight;
  final double? pictureWidth;
  final Alignment pictureAlignment;
  final Widget? trailing;

  const DefinitionHeader({
    super.key,
    required this.pitchSection,
    required this.word,
    this.hanVietLine,
    this.picture,
    this.pictureHeight = 72,
    this.pictureWidth,
    this.pictureAlignment = Alignment.topCenter,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final image = picture;
    final hanViet = hanVietLine;
    final tail = trailing;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              pitchSection,
              Text(
                word,
                style: const TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hanViet != null && hanViet.isNotEmpty)
                Text(
                  hanViet,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        if (image != null) ...[
          const SizedBox(width: 8),
          DescriptivePicture(
            picture: image,
            height: pictureHeight,
            width: pictureWidth,
            alignment: pictureAlignment,
          ),
        ],
        if (tail != null) tail,
      ],
    );
  }
}
