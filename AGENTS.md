# AGENTS.md
# Operational Policies
- **Token Optimization & Request Economy**: You must act with extreme request efficiency. Minimize the overall number of API requests and tool invocations.
- **Batch Adjustments**: Before proposing changes or executing any code/file modifications, you must first gather comprehensive workspace context. 
- **Plan Mode**: Synthesize all required modifications into a single, cohesive, multi-step proposal. Execute the changes in batch workflows rather than sequential, isolated requests.

# Coding standards
- **TDD (Test-Driven Development)** - write the tests first; the implementation
  code isn't done until the tests pass.

DRY (Don't Repeat Yourself) – eliminate duplicated logic by extracting shared utilities and modules.

Separation of Concerns – each module should handle one distinct responsibility.

Single Responsibility Principle (SRP) – every class/module/function/file should have exactly one reason to change.

Clear Abstractions & Contracts – expose intent through small, stable interfaces and hide implementation details.

Low Coupling, High Cohesion – keep modules self-contained, minimize cross-dependencies.

Scalability & Statelessness – design components to scale horizontally and prefer stateless services when possible.

Observability & Testability – build in logging, metrics, tracing, and ensure components can be unit/integration tested.

KISS (Keep It Simple, Sir) - keep solutions as simple as possible.

YAGNI (You're Not Gonna Need It) – avoid speculative complexity or over-engineering.

---
trigger: model_decision
description: Apply these below rules while creating new features, not when fixing bugs
---

# Gemini CLI Guidelines: Flutter & Dart Development

You are an expert Flutter and Dart developer. Your goal is to build beautiful, performant, and maintainable applications following modern best practices.

---

## 1. Interaction & Workflow

* **User Persona:** Assume the user is a mobile app developer (4 years of experience from Flutter 2.10.5 to 3.13.6) but may be new to newer Dart-specific idioms (Flutter latest version).
* **Explanations:** Provide concise explanations for newer Dart-specific features that does not exist previously.
* **Clarifications:** If a requirement is ambiguous, clarify the intended functionality and target platforms (e.g., Android, iOS, Web, Desktop) before implementing.
* **Dependencies:** When proposing packages from `pub.dev`, explain the rationale and trade-offs. Use available `pub_dev_search` / `pub` tooling where applicable.
* **Formatting & Linting:**
  * DO NOT use `dart format` and add new lines/white spaces on existing files. When adding lines to an existing files use format selection if possible or else do not use it. Do not touch existing codes if it is still running fine. ALWAYS format code using `dart format` when creating new files.
  * Fix common errors and deprecations using `dart fix`.
  * Adhere strictly to `flutter_lints`.

---

## 2. Core Architectural Principles

* **SOLID Principles:** Apply SOLID design principles across classes, widgets, and services.
* **Declarative & Functional:** Prefer declarative patterns and concise, modern Dart idioms over imperative boilerplate.
* **Composition over Inheritance:** Build complex widgets and business logic through composition of smaller, specialized components.
* **Immutability:** Keep data models and UI components immutable (`StatelessWidget` preferred). Rebuild instead of mutating state.
* **Separation of Concerns:** Clearly isolate UI, business logic (ViewModel), state management, and data access layers.

---

## 3. Dart Best Practices & Language Standards

* **Effective Dart:** Follow official [Effective Dart](https://dart.dev/effective-dart) guidelines.
* **Sound Null Safety:** Avoid force unwrapping (`!`) unless non-nullability is strictly guaranteed and proven.
* **Modern Dart Features:**
  * **Pattern Matching & Switch Expressions:** Use switch expressions for concise condition handling.
  * **Records:** Use records `(T1, T2)` for multiple return values instead of ad-hoc holder classes.
  * **Arrow Syntax:** Use `=>` for single-expression functions and getters.
* **Asynchronous Programming:**
  * Use `Future`, `async`, and `await` for one-time asynchronous tasks.
  * Use `Stream` for asynchronous data sequences and event feeds.
  * Offload heavy computations (e.g., large JSON parsing) to isolates using `compute()`.
* **Naming Conventions:**
  * `PascalCase`: Classes, enums, typedefs, extension types.
  * `camelCase`: Functions, methods, variables, parameters, named parameters.
  * `snake_case`: File names, directory names, package imports.
  * Avoid cryptic abbreviations.
* **Code Conciseness:** Keep functions short (< 20 lines) and focused on a single responsibility.
* **Error & Exception Handling:**
  * Create and throw specific custom exception classes for domain errors.
  * Never fail silently; handle errors gracefully at the appropriate layer.
  * Use `dart:developer`'s `log()` function instead of `print()`.

---

## 4. Flutter UI & Layout Guidelines

### Widget Construction
* **Micro-Widgets over Helper Methods:** Extract reusable or complex UI chunks into dedicated private `StatelessWidget` classes rather than helper builder methods (e.g., `_buildHeader()`) to optimize element tree rebuilding.
* **Const Constructors:** Use `const` constructors aggressively everywhere possible to minimize unnecessary rebuilds.
* **Pure Build Methods:** Never trigger side effects or expensive asynchronous calls inside `build()`.

### Layout Strategies
* **`Expanded` vs `Flexible`:**
  * Use `Expanded` to make a child fill available space along the main axis.
  * Use `Flexible` when a widget should shrink to fit without forcing expansion.
  * Do not mix `Flexible` and `Expanded` unnecessarily in the same `Row` or `Column`.
* **Scrollables:**
  * For dynamic or long lists/grids, always use builder constructors (`ListView.builder`, `GridView.builder`, `SliverList`).
  * Use `SingleChildScrollView` for fixed-size content that exceeds smaller screen viewports.
* **Overflow Handling:** Use `Wrap` to automatically flow overflowing items to subsequent lines.
* **Responsive Design:** Use `LayoutBuilder` or `MediaQuery` to adapt UI dynamically to available constraints.
* **Stack Positioning:** Use `Positioned` inside `Stack` for explicit edge anchoring.
* **Overlays:** Use `OverlayPortal` for floating UI elements like custom dropdown menus, popovers, or tooltips.
* **Images:** Always supply error and loading builders:
  ```dart
  Image.network(
    'https://example.com/img.png',
    loadingBuilder: (ctx, child, progress) =>
        progress == null ? child : const CircularProgressIndicator(),
    errorBuilder: (ctx, error, stackTrace) => const Icon(Icons.error),
  );
  ```

---

## 5. Visual Design & Theming (Material 3)

* **Design System:** Base visual hierarchy on Material Design 3 guidelines.
* **Theme Configuration:**
  * Centralize styling inside a unified `ThemeData`.
  * Support both Light and Dark modes (`theme` and `darkTheme`).
  * Generate color palettes from seed colors using `ColorScheme.fromSeed`.
  ```dart
  final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
  );
  ```
* **Typography & Visual Hierarchy:** Emphasize typography scale (Hero, Headlines, Subheads) to establish intuitive reading order.
* **Depth & Elevation:**
  * Use layered drop shadows to lift cards and interactive surfaces.
  * Add subtle glow/color shadows to active interactive elements (buttons, sliders, toggles).
  * Apply subtle noise textures to main backgrounds for tactile polish where appropriate.
* **Iconography:** Use consistent, recognizable icons to aid navigation and visual understanding.

---

## 6. State Management & Architecture

### State Management Philosophy
* **Use BloC**.
```

### Architecture: MVVM & Dependency Injection
* **Pattern:** Organize complex feature layers into **Model-View-ViewModel (MVVM)**.
* **Dependency Injection:** Use explicit, constructor-based dependency injection to keep classes testable and modular without hidden global state.

---

## 7. Routing & Navigation (GoRouter)

* Use `go_router` as the standard navigation solution for declarative routing, parameter parsing, deep linking, and web support.
* Handle authentication guards and redirections centrally.

```dart
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'details/:id',
          builder: (context, state) {
            final String id = state.pathParameters['id']!;
            return DetailScreen(id: id);
          },
        ),
      ],
    ),
  ],
);

// App Entrypoint
MaterialApp.router(
  routerConfig: router,
);
```

---

## 8. Data Handling & Serialization

* **Code Generation:** Use `json_serializable` and `json_annotation` for serializing API models.
* **Field Renaming:** Enforce `fieldRename: FieldRename.snake` for consistent JSON mapping.

```dart
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class User {
  final String firstName;
  final String lastName;

  const User({
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
```

---

## 9. Documentation Standards

* **Doc Comments (`///`):** Document all public APIs, classes, parameters, and return types using Dart doc comments (`///`).
* **Summary Sentence:** Start every doc comment with a single concise sentence ending in a period.
* **Explain the "Why":** Focus comments on business logic rationale, constraints, and non-obvious design choices rather than stating what the code trivially does.
* **Consistency:** Maintain uniform naming and domain terminology across documentation.

---

## 10. Accessibility (a11y)

* **Color Contrast:** Maintain a minimum contrast ratio of **4.5:1** for standard text against backgrounds.
* **Dynamic Scaling:** Ensure layouts adapt smoothly to enlarged system accessibility text sizes without clipping.
* **Semantics:** Wrap custom interactive widgets with `Semantics` to provide clear labels and hints for assistive technologies.
* **Testing:** Regularly verify accessibility with screen readers (TalkBack / VoiceOver).

---

## 11. Package & Environment Management

```bash
# Add dependencies
flutter pub add <package>

# Add development dependencies
flutter pub add dev:<package>

# Dependency overrides
flutter pub add override:<package>:<version>

# Remove dependencies
dart pub remove <package>
```

### Static Analysis Configuration (`analysis_options.yaml`)
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_single_quotes: true
    always_use_package_imports: true
```
Flutter app `jisho_anki` — Japanese→VN/EN dictionary with Anki features (flashcards, SRS, pitch accent, offline DBs) plus Gemini-powered LLM lookup. Developed on Windows (PowerShell).

## Commands

```powershell
flutter pub get                                              # after changing pubspec or pulling
flutter gen-l10n                                             # regenerate localizations (also runs automatically: flutter.generate=true)
flutter analyze lib\<path>                                   # targeted analysis; fast, use specific paths
flutter test test\genui_surface_test.dart test\genui_catalog_test.dart   # the meaningful suite; all green
flutter run                                                  # no build_runner/codegen step exists
```

- **Known-broken:** `flutter test test\widget_test.dart` fails because GetIt's `NavigationService` isn't registered in the test env. Pre-existing; don't fix drive-by or treat as your regression.
- No CI workflows exist. Verification = `flutter analyze` + targeted `flutter test`.

## Architecture

- Entry: `lib/main.dart` → `inject()` → `runApp`. Routing: go_router in `lib/config/app_routes.dart` (screens receive args via `state.extra` casts).
- DI: everything through GetIt — register new services in `lib/injection.dart` (mix of `registerLazySingleton` and `registerSingletonAsync`; `await getIt.allReady()` gates app start, so services depending on `SharedPref`/`Dictionary` must declare `dependsOn`).
- Features live in `lib/features/<feature>/{data,domain,presentation}` with bloc per feature (e.g., `MainSearchBloc`). Cross-feature screens import blocs directly.
- Offline data: sqflite databases initialized inside `Dictionary` (`registerSingletonAsync`); lookups go through `KanjiHelper` statics (pitch accent, example sentences, kanji components).
- Settings/API keys: `SharedPref` wrapper over SharedPreferences (`llmEnable`, `llmApiKey`, `llmModel`, custom prompt with `%search_words%`/`%search_sentence%` placeholders). Root `design.md` documents the LLM feature; `plan/genui/guide.md` documents the GenUI/A2UI integration in depth — read it before touching LLM/UI-surface code.

## LLM / GenUI gotchas (hard-won)

- A2UI wire format requires `"version": "v0.9"` in every JSON message; parser silently swallows failures. Only the component with id `"root"` renders. Catalog id is pinned to `'com.jishoanki.dictionary'` in `lib/services/llm/genui_catalog.dart`.
- Prompt choice is caller-driven: `LlmService.buildPrompt/generateExplanationStream(..., useGenUi: true)` selects the A2UI prompt; default is the user's custom settings prompt. Don't branch on the settings flag.
- Widgets like `ExampleSentenceWidget` animate in `initState` — pass stable Future references (cache in State), never `Future.value(x)` inline, or every rebuild replays animations.
- Never render model-provided image URLs; resolve search terms through `WikimediaImageService` (custom User-Agent header required or Wikimedia 403s).

## Conventions (repo-specific)

- **Never run `dart format` on existing files** — it reflows untouched code. Format only new files. This overrides default agent behavior.
- Lints: `avoid_print` (use `dart:developer`'s `log()`) and `prefer_single_quotes` are enforced.
- Localization: two patterns coexist — generated `AppLocalizations` and runtime ternaries on `getIt<SharedPref>().isAppInVietnamese` with hardcoded VN/EN strings. Follow whichever the file you're editing already uses.
- Vendored path dependency: `unofficial_jisho_api` lives in `dependencies/unofficial_jisho_api-3.0.0` (excluded from analyzer). Don't edit it casually.
- Feature work follows TDD per `.agents/rules/architecture-principles.md` (always-on).

## Rule-file conflicts (trust the code)

`.agents/rules/code-style-guide.md` contains generic guidance that does NOT match this codebase:
- It says avoid Bloc and prefer ValueNotifier → this app uses **bloc/flutter_bloc + GetIt** throughout. Keep using Bloc.
- It recommends json_serializable codegen → models here are hand-written; there is no build_runner setup. Don't introduce codegen.
