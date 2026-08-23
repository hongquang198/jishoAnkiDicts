---
trigger: model_decision
description: Apply these rules while creating new features, not when fixing bugs
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
* **Native-First:** Prefer native Flutter primitives: `ValueNotifier`, `ChangeNotifier`, and `ListenableBuilder`.
* **Framework Restrictions:** Do **NOT** introduce heavy external state management libraries (such as Bloc, Riverpod, or GetX) unless explicitly requested by the user.

```dart
// Local / Ephemeral State with ValueNotifier
final ValueNotifier<int> _counter = ValueNotifier<int>(0);

ValueListenableBuilder<int>(
  valueListenable: _counter,
  builder: (context, count, child) {
    return Text('Count: $count');
  },
);
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