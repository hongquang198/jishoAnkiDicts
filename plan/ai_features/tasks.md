# Implementation Tasks: AI Components, UI Surfaces & AI Chat

## Task 1: Prompt Enhancement & Service Layer (TDD)
- [x] **Sub-task 1.1**: Update `LlmService.buildWordInfoPrompt` in `lib/services/llm_service.dart` to bundle borrowed word origin/etymology directly into `tutorComment` and provide comprehensive `memoryTip` formatting.
- [x] **Sub-task 1.2**: Update `test/llm_service_prompt_test.dart` asserting that the prompt requests origin/borrowed word information in `tutorComment` and required schema fields.
- [x] **Sub-task 1.3**: Add `startChatSession({required String initialContext})` method in `LlmService`.

## Task 2: Reusable AI Widget Suite
- [x] **Sub-task 2.1**: Implement `AiLoadingSkeleton` in `lib/common/widgets/ai/ai_loading_skeleton.dart` with smooth shimmer/pulse animation.
- [x] **Sub-task 2.2**: Implement `AiTutorCard` in `lib/common/widgets/ai/ai_tutor_card.dart` supporting loading, error, and content states (including borrowed word context).
- [x] **Sub-task 2.3**: Implement `AiMemoryTipCard` in `lib/common/widgets/ai/ai_memory_tip_card.dart`.
- [x] **Sub-task 2.4**: Implement `AiGrammarBreakdownCard` in `lib/common/widgets/ai/ai_grammar_breakdown_card.dart`.

## Task 3: Screen Integrations (Definition, Grammar & Review)
- [x] **Sub-task 3.1**: Refactor `DefinitionScreen` (`lib/features/word_definition/screens/definition_screen.dart`) to use the new AI component suite with loading indicators and memory tips.
- [x] **Sub-task 3.2**: Integrate `AiMemoryTipCard`, `AiTutorCard`, and `AiGrammarBreakdownCard` into `GrammarPointScreen` (`lib/features/single_grammar_point/screen/grammar_point_screen.dart`).
- [x] **Sub-task 3.3**: Integrate AI component cards into `ReviewScreen` / `build_card_widget.dart` for enrolled cards.

## Task 4: Interactive Multi-Turn AI Chat
- [x] **Sub-task 4.1**: Create `AiChatBloc` (`lib/features/ai_chat/bloc/ai_chat_bloc.dart`) managing chat history and streaming responses.
- [x] **Sub-task 4.2**: Implement `AiChatScreen` (`lib/features/ai_chat/screens/ai_chat_screen.dart`) with quick suggestion chips, message bubbles, and streaming input bar.
- [x] **Sub-task 4.3**: Add `AppRoutes.aiChat` route in `lib/config/app_routes.dart` and register `AiChatBloc` in `lib/injection.dart`.
- [x] **Sub-task 4.4**: Add "Ask AI Tutor" action buttons in `DefinitionScreen`, `GrammarPointScreen`, and `ReviewScreen`.
- [x] **Sub-task 4.5**: Write unit tests for `AiChatBloc` in `test/ai_chat_bloc_test.dart`.

## Task 5: Verification
- [x] **Sub-task 5.1**: Run `flutter analyze` on touched packages.
- [x] **Sub-task 5.2**: Run `flutter test` across all updated test suites.
