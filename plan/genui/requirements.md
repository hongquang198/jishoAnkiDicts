# LLM UI Integration Plan ("genui")

## Objective
To align the LLM-generated dictionary lookup output with the application's existing design system used in `DefinitionScreen`, leveraging the official **Flutter GenUI SDK** and the **A2UI (Agent-to-UI) protocol** to dynamically compose native widgets (`DefinitionWidget`, `ExampleSentenceWidget`, `ComponentWidget`).

## Technical Analysis
Rather than writing an ad-hoc custom JSON parser and buffering stream reader manually, we will use the official `genui` package:
1.  **Catalog Registration**: Expose existing UI widgets (`DefinitionWidget`, `ExampleSentenceWidget`, `ComponentWidget`) as `CatalogItem`s in a GenUI `Catalog`.
2.  **A2UI Protocol**: Use the standard A2UI protocol commands (`createSurface`, `updateComponents`) to let the LLM instruct the client how to construct the definition card view dynamically.
3.  **Client-Side Rendering**: Integrate `SurfaceController` and the `Surface` widget inside `LlmSearchResultTile` to handle the rendering lifecycle automatically.

## Proposed Architecture
1.  **Catalog Layer**: Define `CatalogItem` specifications for each UI component including their schemas (using `json_schema_builder`).
2.  **Surface Controller**: A `SurfaceController` instance will manage the state of the definition surface and process incoming A2UI commands from the LLM.
3.  **LlmSearchResultTile Refactor**:
    *   Change the tile to host a `Surface` widget bound to the `SurfaceController`.
    *   Initialize the controller with the vocabulary of our dict widgets catalog.
4.  **Prompt & Agent Integration**: Inform the LLM of the available widget schemas so it can correctly output A2UI protocol messages.

## Implementation Phases

### Phase 1: Research & Schema Definition
*   Define the schemas for `DefinitionWidget`, `ExampleSentenceWidget`, and `ComponentWidget`.
*   Formulate catalog items matching `CatalogItem` API.

### Phase 2: Controller & surface integration
*   Create the widget catalog and register items.
*   Integrate `SurfaceController` and `Surface` into `LlmSearchResultTile`.

### Phase 3: Adapter & Protocol Parsing
*   Connect the LLM's response stream to the `SurfaceController` via an A2UI transport adapter or by feeding A2UI protocol stream chunks directly.

### Phase 4: Validation
*   Verify that visual updates to widgets are reflected automatically in the generative UI.

## Testing Plan
*   Unit tests for `CatalogItem` construction and schema validation.
*   Widget tests to verify `Surface` rendering based on incoming A2UI payloads.
