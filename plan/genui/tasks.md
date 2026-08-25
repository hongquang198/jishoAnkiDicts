# Implementation Tasks: LLM-UI Integration (genui)

This document outlines the step-by-step tasks to implement the GenUI feature with dual-mode toggleability utilizing the official `genui` package.

## Task 1: Package setup & Catalog definition
*   **Sub-task 1.1**: Add `genui` and `json_schema_builder` dependencies to `pubspec.yaml`.
*   **Sub-task 1.2**: Define `CatalogItem` mappings in `lib/services/llm/genui_catalog.dart` for:
    *   `DefinitionWidget`
    *   `ExampleSentenceWidget`
    *   `ComponentWidget`
*   **Sub-task 1.3**: Write unit tests for Catalog schema definition and validation.

## Task 2: Settings & Toggle Integration
*   **Sub-task 2.1**: Update `SharedPreferences` settings and the UI settings view to support toggling between "Raw Text" and "Generative UI (GenUI)" mode.
*   **Sub-task 2.2**: Configure LLM prompt instructions to output A2UI protocol commands when GenUI mode is active.

## Task 3: UI Integration (`LlmSearchResultTile`)
*   **Sub-task 3.1**: Initialize `SurfaceController` with our catalog inside `LlmSearchResultTile`.
*   **Sub-task 3.2**: Replace or wrap raw text display in `LlmSearchResultTile` with a `Surface` widget tied to the controller.
*   **Sub-task 3.3**: Write widget tests to verify that `Surface` successfully renders the components when fed matching A2UI inputs.
