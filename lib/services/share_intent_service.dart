import 'dart:async';
import 'dart:io';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Handles incoming shared text from Android's share sheet.
class ShareIntentService {
  ShareIntentService._();

  static final ShareIntentService instance = ShareIntentService._();

  final _sharedTextController = StreamController<String>.broadcast();
  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;

  /// Emits shared text when the app receives it from another app.
  Stream<String> get sharedTextStream => _sharedTextController.stream;

  Future<void> init() async {
    if (!Platform.isAndroid) return;

    final initialMedia = await ReceiveSharingIntent.instance.getInitialMedia();
    _emitSharedText(initialMedia);
    await ReceiveSharingIntent.instance.reset();

    _mediaSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen((media) async {
      _emitSharedText(media);
      await ReceiveSharingIntent.instance.reset();
    });
  }

  void _emitSharedText(List<SharedMediaFile> media) {
    for (final item in media) {
      if (item.type == SharedMediaType.text && item.path.isNotEmpty) {
        _sharedTextController.add(item.path);
        return;
      }
    }
  }

  void dispose() {
    _mediaSubscription?.cancel();
    _sharedTextController.close();
  }
}
