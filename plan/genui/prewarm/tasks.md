# Implementation Tasks: GenUI Prewarm

Sequential execution plan for the design in [design.md](design.md). Follow
TDD per repo rules — write each task's tests first; the implementation is not
done until they pass. Verify every task with targeted analysis before moving
on:

```powershell
flutter analyze lib\<changed-paths> test\<new-test>
```

## Task 1: Image service — width parameter & preload support
*   **Sub-task 1.1**: Write unit tests for the new API first:
    *   `fetchThumbnailUrl(term)` still defaults to width 600.
    *   `fetchThumbnailUrl(term, width: 320)` requests `iiurlwidth=320`.
    *   Empty/whitespace term returns null without any HTTP call.
*   **Sub-task 1.2**: Add `{int width = 600}` to
    `WikimediaImageService.fetchThumbnailUrl` (`lib/services/wikimedia_image_service.dart`).
*   **Sub-task 1.3**: Add `PreloadedImage` value type in the same file
    (or a sibling): resolved `url` + ready-to-render `ImageProvider`
    (`ResizeImage(Image.network(url).image, width: 240)`), plus a loader that
    warms Flutter's image cache via `PaintingBinding.instance.imageCache`
    with `ImageConfiguration.empty` (no BuildContext).
*   **Sub-task 1.4**: Run Task 1 tests until green.

## Task 2: `GenUiDataPrefetch` bundle & cache
*   **Sub-task 2.1**: Write unit tests (`test/gen_ui_data_prefetch_test.dart`) first,
    using fake services/blocs:
    *   `warm` is idempotent per trimmed query (no duplicate lane starts).
    *   FIFO eviction at 8 entries drops the oldest key.
    *   Lanes resolve independently — one throwing lane must not fail the others.
    *   Image stage logic: local-term hit short-circuits; local-term miss
        upgrades to the LLM `imageQuery` term exactly once.
    *   LLM-gated lanes do not start when `llmEnable`/API key is absent;
        local DB and Wikimedia lanes always run.
*   **Sub-task 2.2**: Create `lib/services/llm/gen_ui_data_prefetch.dart`:
    *   `GenUiDataPrefetch` holding eagerly-started futures per design §3:
        `wordInfo`, `image`, `pitchWidgets`, `examples`, `kanjiComponents`.
    *   `GenUiDataPrefetchCache` mirroring `GenUiPrefetchCache`
        (bounded 8, FIFO, keyed by trimmed query); disposal drops references
        only (futures are not cancellable — document this divergence).
*   **Sub-task 2.3**: Run Task 2 tests until green.

## Task 3: Dependency injection
*   **Sub-task 3.1**: Register `GenUiDataPrefetchCache` as a lazy singleton in
    `lib/injection.dart` next to `GenUiPrefetchCache`. No `dependsOn`
    required (lanes tolerate absence individually).
*   **Sub-task 3.2**: Confirm `flutter analyze lib\injection.dart` is clean.

## Task 4: Tile-side prewarm trigger
*   **Sub-task 4.1**: In `_startStreaming()`
    (`lib/features/main_search/presentation/screens/widgets/llm_search_result_tile.dart`),
    call `getIt<GenUiDataPrefetchCache>().warm(...)` beside the existing A2UI
    `warm(...)`, passing query, services, and the bloc-matched
    `JishoDefinition` (reuse the matching logic from
    `GenUiDefinitionScreen._resolveBlocData`).
*   **Sub-task 4.2**: Gate check per design §4: runs regardless of
    `llmGenUiEnable`; only `wordInfo` respects `llmEnable && apiKey`.

## Task 5: Screen attachment refactor
*   **Sub-task 5.1**: In `gen_ui_definition_screen.dart`:
    *   Attach to `GenUiDataPrefetchCache.get(query)` in `initState`;
        warm-fresh when missing (deep-link parity with the A2UI prefetch).
    *   Replace `_loadLocalDictionaryData` / `_fillGapsFromLlm` /
        `_loadTutorSection` orchestration with awaits on shared futures.
    *   Assign each future to a State field exactly once (stable-future rule);
        swap `_examplesFuture` only when empty-local → LLM sentences replaces data.
    *   Render the picture via `Image(image: preloaded.provider, ...)` instead
        of `Image.network(url)`.
    *   AppBar badges unchanged: bloc-first, `wordInfo` async fallback.
*   **Sub-task 5.2**: Manual sanity pass via `flutter run`: tile appears →
    tap sparkle icon → badges/examples/picture/tutor comment visible with no
    sequential loading spinners.

## Task 6: Widget test for the attached screen
*   **Sub-task 6.1**: Write widget test first: pump `GenUiDefinitionScreen`
    with a stubbed `GenUiDataPrefetchCache`; fake services assert **zero**
    invocations during build/attach.
*   **Sub-task 6.2**: Assert rendering: badges (`common word` chip),
    example sentences, picture from the preloaded provider, tutor comment card.
*   **Sub-task 6.3**: Make the test pass by fixing any integration gaps found.

## Task 7: Verification & documentation
*   **Sub-task 7.1**: Run the full relevant suite:
    ```powershell
    flutter analyze lib\services\llm lib\services\wikimedia_image_service.dart lib\injection.dart lib\features\main_search
    flutter test test\gen_ui_data_prefetch_test.dart test\genui_surface_test.dart test\genui_catalog_test.dart
    ```
*   **Sub-task 7.2**: Create `readme.md` in `plan/genui/prewarm/` summarizing:
    what was built (one paragraph), files touched, how to verify manually,
    and known trade-offs (three concurrent Gemini-related calls; futures not
    cancellable on eviction — see design.md §§9–11).
*   **Sub-task 7.3**: Update `readme.md` after implementation with anything
    learned that diverged from design.md (gotchas, actual widths/timings),
    keeping design.md as the original intent record.
