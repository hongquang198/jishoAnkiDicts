# Design Specification: GenUI Prewarm (full-screen data preloading)

## Overview
Today only the **A2UI explanation stream** is pre-warmed when a search-result
tile appears (`GenUiPrefetchCache`). Everything else on
`GenUiDefinitionScreen` — descriptive picture, common/tags/JLPT badges,
example sentences, AI-tutor comment — still starts *after* the user taps the
sparkle icon. This document defines the design for pre-warming **all** of those
lanes at tile-appear time, so tapping the AI icon shows a fully-populated
screen as fast as possible.

## 1. Current timeline vs. target

```
TODAY (after tap):                                TARGET (after tap):
tap ──► route push                                 tap ──► route push
  ├─ local DB (pitch/examples/kanji)   ~10-50 ms     └─ all data ALREADY in memory
  ├─ fetchWordInfo (Gemini)            ~1-4 s            (started when tile appeared)
  ├─ Wikimedia URL search              ~0.3-1 s          → instant badges, examples,
  └─ image bytes download + decode     ~0.5-2 s            tutor comment, picture
                                     ----------          (bytes already decoded in
                                      worst ~6 s          Flutter's image cache)
```

Note the two **sequential** hops today inside `_fillGapsFromLlm` →
`_loadTutorSection`: the Wikimedia lookup cannot even start until
`fetchWordInfo` returns (it wants the model's `imageQuery` term). Removing
that serialization matters as much as moving the work earlier.

## 2. Goals & Non-goals

**Goals**
- Start every data lane the moment the tile appears, concurrently.
- Image: lowest acceptable quality (small thumbnail + bounded decode) and
  pre-decoded into the image cache before navigation.
- No duplicated network work between tile-time and screen-time (shared
  `Future` instances, memoized by construction).
- Preserve all existing guarantees: never render model-provided URLs,
  local-data-over-LLM precedence, stable future references (gotcha #5 of
  guide.md §7).

**Non-goals**
- Not changing the A2UI prompt/wire format (tutor comment stays in
  `fetchWordInfo`).
- Not caching across app restarts or persisting to disk.
- Not touching the inline text-mode expansion of the tile.

## 3. Architecture: a sibling prefetch unit

Follow the proven `GenUiPrefetch` pattern instead of growing it (SRP — stream
buffering and structured-data resolution are different reasons to change):

| Piece | File | Responsibility |
|---|---|---|
| `GenUiDataPrefetch` | `lib/services/llm/gen_ui_data_prefetch.dart` | Owns the eagerly-started `Future`s for one query |
| `GenUiDataPrefetchCache` | same file | Bounded (8, FIFO) map keyed by trimmed query, mirroring `GenUiPrefetchCache` |
| Wiring | `lib/injection.dart` | `registerLazySingleton<GenUiDataPrefetchCache>` |

### The bundle

```dart
class GenUiDataPrefetch {
  final String query;
  // Structured gap-fill: tutorComment, imageQuery, isCommon/tags/jlpt,
  // sentences fallback. Null on failure / LLM disabled.
  final Future<Map<String, dynamic>?> wordInfo;
  // Wikimedia thumbnail URL + PRELOADED bytes (see §5).
  final Future<PreloadedImage?> image;
  // Local DB lanes (always run, no API key needed).
  final Future<List<Widget>> pitchWidgets;
  final Future<List<ExampleSentence>> examples;
  final Future<List<Kanji>> kanjiComponents;
}
```

`PreloadedImage` carries the resolved `url` plus a ready-to-render
`ImageProvider` whose bytes/decode already sit in Flutter's image cache.

Dart `Future`s are natural attach points: every awaiter of the same instance
gets the same result with zero extra cost, so "attach" is just
`prefetch.examples` on the screen side — no snapshot/subscribe dance needed
(unlike the chunked A2UI stream).

## 4. Prewarm lanes

Started from `llm_search_result_tile._startStreaming()` (the same post-frame
hook that already warms the A2UI stream):

| Lane | Source | Gate | Depends on |
|---|---|---|---|
| A2UI stream (existing) | `generateExplanationStream(useGenUi: true)` | `llmEnable && llmGenUiEnable && key` | — |
| Word info | `LlmService.fetchWordInfo(query)` | `llmEnable && key` | — |
| Pitch widgets | `KanjiHelper.getPitchAccent` | none | — |
| Example sentences | `KanjiHelper.getExampleSentence` (localized table → English fallback) | none | — |
| Kanji components | `KanjiHelper.getKanjiComponent` | none | — |
| Image URL + preload | `WikimediaImageService.fetchThumbnailUrl(term, width: 320)` then byte preload | none | search term (see §5) |

Bloc-held data (`_jishoDefinition.isCommon/tags/jlpt`, `hanVietMap`) needs no
lane: the tile passes `context.read<MainSearchBloc>()` through the existing
route args, exactly as today — badges render synchronously from bloc state,
with `wordInfo`'s `isCommon/tags/jlpt` as async fallback once it resolves.

The tile constructs the prefetch with the jisho definition extracted from bloc
state (same matching logic as `_resolveBlocData`), because the image-term
fallback chain needs the first English sense:

```
term = wordInfo.imageQuery  (when it lands, see below)
     → first englishDefinition of bloc's matched JishoDefinition
     → raw query
```

## 5. Image pipeline (fast + reduced quality)

Rendered box is 120×120 logical px ⇒ ≤360 device px at DPR 3. Today we ask
Wikimedia for `iiurlwidth=600` and download at navigation time.

1. **Smaller transfer**: parameterize
   `WikimediaImageService.fetchThumbnailUrl(String searchTerm, {int width})`
   and request **width 320** at prewarm time (~⅓ the pixel count of 600,
   visually identical at 120 pt). Keep the default 600 for any other caller.
2. **Start early, upgrade only on miss** (removes the sequential hop):
   - Immediately kick off the lookup with the best **local** term
     (bloc English sense → raw query).
   - When `wordInfo` resolves: if its `imageQuery` differs and the local-term
     lookup returned `null` (or hasn't found anything yet), retry **once**
     with the LLM term. If an image was already found, keep it — the model's
     term is a nice-to-have, not worth a second download or a late swap.
3. **Pre-decode**: with the resolved URL, build the provider
   `ResizeImage(Image.network(url).image, width: 240)` (bounds decoded
   memory; 240 ≈ 120 pt × 2 DPR) and warm it **without a BuildContext** via
   `PaintingBinding.instance.imageCache` /
   `provider.obtainKey(ImageConfiguration.empty)` + `loadImage`. By tap time
   the bytes are downloaded *and* decoded; the widget's first frame paints
   from cache.
4. **Render**: the screen uses `Image(image: preloaded.provider, ...)` —
   `loadingBuilder` stays as a defensive fallback but should never show.

Preserved invariant: only the search *term* may come from the model; the URL
always comes from the real Wikimedia query (guide.md hard-won rule).

## 6. Sequencing

```mermaid
sequenceDiagram
    participant T as LlmSearchResultTile
    participant DC as GenUiDataPrefetchCache
    participant LS as LlmService
    participant WI as WikimediaImageService
    participant KH as KanjiHelper (local DB)

    Note over T: post-frame after tile appears
    par A2UI stream (existing)
        T->>DC: warm(query)
    and structured gap-fill
        T->>LS: fetchWordInfo(query)
    and local DB lanes
        T->>KH: pitch / examples / kanji components
    and image (stage 1: local term)
        T->>WI: fetchThumbnailUrl(localTerm, width: 320)
        WI-->>T: url → preload bytes into image cache
    end
    Note over LS,WI: wordInfo lands → optional stage-2<br/>retry with imageQuery if stage 1 missed
    U->>T: taps sparkle icon
    Note over T: pushNamed(/gen-ui-definition)
    T-->>U: screen attaches to the SAME Future instances;<br/>badges, examples, picture, tutor comment paint immediately
```

## 7. Integration changes

### `llm_search_result_tile.dart`
In `_startStreaming()`, next to the existing `GenUiPrefetchCache.warm(...)`,
call `getIt<GenUiDataPrefetchCache>().warm(...)` passing: query, llmService,
wikimediaImageService, and the matched `JishoDefinition` from bloc state.
Runs regardless of `llmGenUiEnable` (picture/badges/examples are shown by the
screen in every mode where the sparkle icon exists).

### `gen_ui_definition_screen.dart`
- `initState` attaches to the caches instead of orchestrating work:
  `dataPrefetch = cache.get(query) ?? cache-created-fresh` (fresh start keeps
  deep-links working — same policy as the A2UI prefetch).
- Delete `_loadLocalDictionaryData` / `_fillGapsFromLlm` /
  `_loadTutorSection` bodies; replace with awaits on the shared futures.
- **Stable-future rule**: assign each future to a State field exactly once
  (`_examplesFuture`, etc.) and swap only when data genuinely replaces
  (empty-local → LLM sentences), preserving gotcha #5.
- Image section switches from `Image.network(url)` to the preloaded provider.
- AppBar badge logic unchanged (bloc-first, `wordInfo` fallback).

### `injection.dart`
One new lazy singleton. No `dependsOn` needed — lanes tolerate absence of
data and fail individually.

## 8. Alternatives considered

| Alternative | Verdict |
|---|---|
| Fold `tutorComment`/`imageQuery` into the A2UI prompt | Rejected: breaks the strict single-component envelope; inline text mode would lose the comment; complicates catalog schemas |
| Store everything inside `GenUiPrefetch` | Rejected: mixes stream-buffering with data resolution; A2UI lane is gated differently than local/image lanes |
| Skip prefetch, just parallelize on-screen | Rejected: doesn't remove the tap-to-content latency, only the serialization within it |
| Always prefer the LLM `imageQuery` (wait for wordInfo) | Rejected: reintroduces the serial hop; local-term-first with one upgrade-on-miss gets an image on screen sooner |

## 9. Concurrency budget & trade-offs

While a tile is visible with LLM enabled there will be up to **three**
outbound Gemini-related calls (inline text stream, A2UI stream, word info)
plus one Wikimedia call. This matches the existing philosophy ("duplication
is the price of near-instant results"), adds one structured (non-streaming,
usually cheaper) call, and is capped by the FIFO=8 caches. If quota becomes a
concern, `wordInfo` is the lane to gate behind a setting — its UI impact is
limited to fallback badges/sentences plus the tutor comment.

## 10. Testing

- Unit tests (`test/gen_ui_data_prefetch_test.dart`):
  - `warm` is idempotent per query; FIFO eviction drops the oldest entry.
  - Image stage logic: local-term hit short-circuits; miss upgrades to LLM
    term exactly once.
  - Lanes resolve independently — one failing lane (throwing fake service)
    must not fail the others.
- Widget test: `GenUiDefinitionScreen` fed a stubbed cache renders badges,
  example sentences, picture and tutor comment **without** issuing new
  service calls (fake services assert zero invocations).
- Existing suites stay green:
  ```powershell
  flutter test test\genui_surface_test.dart test\genui_catalog_test.dart
  ```

## 11. Risks & gotchas

1. **Futures are not cancellable** — evicted prefetches keep running to
   completion. Accepted: each lane is small and keyed; disposal just drops
   references (documented divergence from `GenUiPrefetch.dispose()`).
2. **Precache without context** — must use
   `PaintingBinding.instance.imageCache` + `ImageConfiguration.empty`;
   a `BuildContext`-based `precacheImage` would couple the service layer to
   widgets and break from a tile context.
3. **Wikimedia User-Agent** — mandatory custom UA (403 otherwise) lives in
   `WikimediaImageService`; do not bypass the service with raw `http.get`.
4. **Animation replay** — any future handed to `ExampleSentenceWidget` must
   be the cached field, never an inline `Future.value` (gotcha #5).
5. **Regenerate button** refreshes only the A2UI stream; picture/tutor
   comment/badges are query-scoped and intentionally reused from the cache.
