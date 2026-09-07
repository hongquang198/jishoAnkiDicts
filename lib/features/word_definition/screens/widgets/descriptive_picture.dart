import 'package:flutter/material.dart';

import '../../../../services/preloaded_image.dart';

/// Rounded AI descriptive picture shared by the detail-screen headers.
///
/// Shows [picture] with a slim loading spinner and collapses to nothing on
/// load errors, so both detail screens share one image treatment.
class DescriptivePicture extends StatelessWidget {
  final PreloadedImage picture;
  final double height;
  final double? width;
  final Alignment alignment;

  const DescriptivePicture({
    super.key,
    required this.picture,
    this.height = 72,
    this.width,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image(
          image: picture.provider,
          height: height,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : SizedBox(
                  height: height,
                  width: width,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFDB8C8A),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
