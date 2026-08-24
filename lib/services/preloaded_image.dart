import 'dart:async';

import 'package:flutter/painting.dart';

/// A resolved image URL paired with an [ImageProvider] whose bytes were
/// already downloaded and decoded into the shared image cache, so the first
/// frame paints without any loading state.
class PreloadedImage {
  const PreloadedImage({required this.url, required this.provider});

  final String url;
  final ImageProvider provider;
}

/// Builds the provider used for both preloading and rendering: network bytes
/// downscaled at decode time to [decodeWidth] device pixels (the render box is
/// roughly 120 logical px, so 240 covers DPR 2 comfortably).
ImageProvider buildPreloadProvider(String url, {int decodeWidth = 240}) =>
    ResizeImage(NetworkImage(url), width: decodeWidth);

/// Downloads and decodes [url] into Flutter's image cache WITHOUT a
/// BuildContext, then returns a [PreloadedImage] that renders from that cache.
///
/// Resolving the provider and listening until the first frame is available
/// populates `PaintingBinding.instance.imageCache`; later `resolve()` calls on
/// the same provider reuse the cached completer. Returns null instead of
/// throwing when the download or decode fails — decorative pictures stay
/// best-effort by design.
Future<PreloadedImage?> preloadImage({
  required String url,
  int decodeWidth = 240,
  ImageProvider Function(String url, int decodeWidth)? buildProvider,
}) async {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return null;
  final provider = buildProvider?.call(trimmed, decodeWidth) ??
      buildPreloadProvider(trimmed, decodeWidth: decodeWidth);

  final stream = provider.resolve(ImageConfiguration.empty);
  final firstFrame = Completer<bool>();
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (_, __) {
      if (!firstFrame.isCompleted) firstFrame.complete(true);
      stream.removeListener(listener);
    },
    onError: (_, __) {
      if (!firstFrame.isCompleted) firstFrame.complete(false);
      stream.removeListener(listener);
    },
  );
  stream.addListener(listener);

  final loaded = await firstFrame.future;
  if (!loaded) return null;
  return PreloadedImage(url: trimmed, provider: provider);
}
