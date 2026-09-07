part of 'gen_ui_definition_screen.dart';

/// AI explanation streaming for [GenUiDefinitionScreen].
///
/// Owns the [SurfaceController]/transport lifecycle, which is inherently
/// widget-bound: the controller must be created, fed, and disposed with the
/// screen. Stream *status* is kept as plain state fields for `build`.
extension _GenUiDefinitionStreamingExt on _GenUiDefinitionScreenState {
  /// Starts (or attaches to) the AI explanation stream.
  ///
  /// With [regenerate] the cached prefetch for this query is discarded first
  /// so a genuinely fresh request is issued; without it an in-flight or
  /// completed pre-warmed response is re-attached transparently.
  void _startStreaming({bool regenerate = false}) {
    final sharedPref = getIt<SharedPref>();
    final llmService = getIt<LlmService>();

    if (!sharedPref.llmEnable) return;
    if (sharedPref.llmApiKey.trim().isEmpty) {
      _update(() {
        _isStreaming = false;
        _errorMessage = 'missing_key';
      });
      return;
    }

    _subscription?.cancel();
    _messageSubscription?.cancel();
    _transportAdapter?.dispose();
    _surfaceController?.dispose();

    _update(() {
      _receivedA2uiContent = false;
      _errorMessage = null;
      _isStreaming = true;
    });

    _surfaceController = SurfaceController(catalogs: [genUiCatalog]);
    _transportAdapter = A2uiTransportAdapter();

    _messageSubscription = _transportAdapter!.incomingMessages.listen(
      (message) {
        if (!mounted) return;
        if (message is core.UpdateComponentsMessage) {
          _receivedA2uiContent = true;
        }
        _surfaceController?.handleMessage(message);
        _update(() {});
      },
      onError: (error) {
        if (mounted) {
          _update(() {
            _isStreaming = false;
            _errorMessage = error.toString();
          });
        }
      },
    );

    // Create the surface deterministically on the client so it always exists,
    // regardless of what the model streams. The model only needs to supply
    // the updateComponents payload.
    _surfaceController!.handleMessage(
      core.CreateSurfaceMessage(
        surfaceId: _GenUiDefinitionScreenState._surfaceId,
        catalogId: genUiCatalogId,
      ),
    );

    // Attach to the pre-warmed GenUI response for this query (started by the
    // search-result tile when it appeared). If none exists — e.g. the screen
    // was opened without passing through the tile — this transparently starts
    // a fresh stream.
    final prefetchCache = getIt<GenUiPrefetchCache>();
    if (regenerate) prefetchCache.invalidate(currentJapaneseWord);
    prefetchCache.warm(
      currentJapaneseWord,
      startStream: () => llmService
          .generateExplanationStream(currentJapaneseWord, useGenUi: true),
    );
    final prefetch = prefetchCache.get(currentJapaneseWord)!;

    if (prefetch.error != null) {
      _update(() {
        _isStreaming = false;
        _errorMessage = prefetch.error;
      });
      return;
    }

    final attachment = prefetch.attach(
      (chunk) {
        if (!mounted) return;
        _transportAdapter?.addChunk(chunk);
        _update(() {});
      },
      onDone: () {
        if (!mounted) return;
        _update(() {
          _isStreaming = false;
          if (prefetch.error != null) _errorMessage = prefetch.error;
        });
      },
    );
    _subscription = attachment.sub;
    if (attachment.snapshot.isNotEmpty) {
      _transportAdapter?.addChunk(attachment.snapshot);
    }
    if (prefetch.isDone) {
      _update(() => _isStreaming = false);
    }
  }
}
