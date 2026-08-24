# GenUI Prewarm — Implementation Notes

This feature pre-warms **everything** the `GenUiDefinitionScreen` needs while
the search-result tile is still on screen, so tapping the sparkle icon paints
a fully-populated page (badges, examples, descriptive picture, AI-tutor
comment) with no sequential loading spinners.

- Intent & architecture: [design.md](design.md)
- Execution plan: [tasks.md](tasks.md)

## What was built (summary)

When a search-result tile appears (`_startStreaming`, post-frame), it now
starts — alongside the existing A2UI stream warm — a
`GenUiDataPrefetchCache.warm(...)` entry whose lanes run concurrently:

| Lane | Source | Result |
|---|---|---|
| Word info | `LlmService.fetchWordInfo` | tutor comment, badge fallbacks (`isCommon`/`tags`/`jlpt`), sentences fallback |
| Picture | Wikimedia search @ 320 px + byte preload/decode @ 240 px | `PreloadedImage` rendering instantly from the image cache |
| Pitch / examples / kanji | `KanjiHelper` local DBs | sections ready before navigation |

Image staging: search with the best **local** term first; only if that misses
does it retry once with the model's `imageQuery`. A hit never waits for the
LLM. The screen attaches to the same memoized futures — zero duplicate
requests.

## Files touched

- `lib/services/preloaded_image.dart` (new) — cache-warming image loader
- `lib/services/wikimedia_image_service.dart` — injectable client + width param
- `lib/services/llm/gen_ui_data_prefetch.dart` (new) — lane bundle + FIFO cache
- `lib/injection.dart` — `GenUiDataPrefetchCache` singleton
- `lib/features/main_search/presentation/screens/widgets/llm_search_result_tile.dart` — warm trigger
- `lib/features/main_search/presentation/screens/gen_ui_definition_screen.dart` — attach refactor + shared starter wiring
- `lib/features/word_definition/screens/widgets/example_sentence_widget.dart` — dispose assert fix
- Tests: `test/wikimedia_image_service_test.dart`,
  `test/gen_ui_data_prefetch_test.dart`, `test/gen_ui_screen_prewarm_test.dart`

## Verify

```powershell
flutter analyze lib\services lib\injection.dart lib\features\main_search
flutter test test\gen_ui_data_prefetch_test.dart test\wikimedia_image_service_test.dart test\gen_ui_screen_prewarm_test.dart test\genui_catalog_test.dart test\genui_surface_test.dart
```

Manual pass: search a word → tap the sparkle icon quickly → badges/examples/
picture/tutor note should already be present (picture may still download on
very slow connections; everything else renders immediately).

## Divergences & lessons learned

1. **Shared lane wiring lives in the screen file** (`startDefaultDataPrefetch`
   + `loadLocalizedExamples`, top-level in `gen_ui_definition_screen.dart`),
   not in the service layer — the tile already imports the screen, avoiding a
   services→features import and keeping one source of truth.
2. **`KanjiHelper.getPitchAccent/getExampleSentence` never used their required
   `BuildContext`** — verified, then made the parameter optional so prewarm
   lanes don't capture or cross async gaps with a context.
3. **Latent bug fixed**: `_ExampleSentenceWidgetState.dispose` called
   `OverlayEntry.remove()` on an entry that was never inserted (the insert has
   been commented out for a long time) — debug builds asserted on every
   screen close with examples mounted.
4. **Widget-test gotcha**: attaching `.then` listeners to futures that were
   created *outside* the test body's FakeAsync zone does not flush during
   `tester.pump()`. Warm the cache inside `testWidgets`.
5. `DefinitionTags` renders tag text padded with spaces (`' N4 '`) — matchers
   must include them.
6. Decode/transfer constants: thumbnail width 320 px, decode bound 240 px
   (`kPrewarmThumbnailWidth` / `kPrewarmDecodeWidth`) — sized for the 120×120
   render box.
