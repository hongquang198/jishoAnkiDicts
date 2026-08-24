import 'dart:async';

/// A warmed GenUI (A2UI protocol) LLM response for one query.
///
/// The search-result tile starts a prefetch as soon as it appears so that,
/// by the time the user taps the sparkle icon button, most (or all) of the
/// response has already been received. The GenUI screen attaches to the
/// in-flight or completed prefetch instead of issuing a second request.
class GenUiPrefetch {
  GenUiPrefetch._(this.query, Stream<String> stream) {
    _subscription = stream.listen(
      _append,
      onError: (Object e) {
        error = e.toString();
        isDone = true;
        _updates.close();
      },
      onDone: () {
        isDone = true;
        _updates.close();
      },
    );
  }

  final String query;

  /// Everything received so far (raw chunks concatenated).
  String accumulated = '';

  /// True once the underlying stream finished (successfully or with an error).
  bool isDone = false;

  /// Error message from the underlying stream, if it failed.
  String? error;

  final StreamController<String> _updates = StreamController.broadcast();
  StreamSubscription<String>? _subscription;

  void _append(String chunk) {
    accumulated += chunk;
    _updates.add(chunk);
  }

  /// Atomically subscribes [onChunk] to future appends and returns the
  /// current [snapshot] of everything received so far. Dart's single-threaded
  /// event loop guarantees no chunk is lost or duplicated in between.
  ///
  /// [onDone] fires when the underlying stream finishes (including after an
  /// error — check [error] there).
  ({String snapshot, StreamSubscription<String> sub}) attach(
    void Function(String chunk) onChunk, {
    void Function()? onDone,
  }) {
    final sub = _updates.stream.listen(
      onChunk,
      onDone: onDone ?? () {},
      cancelOnError: true,
    );
    return (snapshot: accumulated, sub: sub);
  }

  void dispose() {
    _subscription?.cancel();
    _updates.close();
  }
}

/// Bounded cache of in-flight/completed [GenUiPrefetch]s keyed by query.
///
/// Registered as a lazy singleton in `injection.dart` — resolve via
/// `getIt<GenUiPrefetchCache>()`.
class GenUiPrefetchCache {
  GenUiPrefetchCache();

  final Map<String, GenUiPrefetch> _entries = {};
  static const int _maxEntries = 8;

  /// Starts prefetching [query] unless an entry already exists.
  ///
  /// [startStream] is only invoked when a new entry is created.
  void warm(String query, {required Stream<String> Function() startStream}) {
    final key = query.trim();
    if (key.isEmpty || _entries.containsKey(key)) return;
    _evictIfNeeded();
    _entries[key] = GenUiPrefetch._(key, startStream());
  }

  GenUiPrefetch? get(String query) => _entries[query.trim()];

  /// Removes and disposes the entry for [query], if present.
  void invalidate(String query) {
    _entries.remove(query.trim())?.dispose();
  }

  void _evictIfNeeded() {
    while (_entries.length >= _maxEntries) {
      final oldestKey = _entries.keys.first;
      _entries.remove(oldestKey)?.dispose();
    }
  }
}
