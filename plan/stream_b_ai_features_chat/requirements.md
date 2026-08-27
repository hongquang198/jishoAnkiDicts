# Stream B Requirements: AI Components, UI Surfaces & AI Chat

## 1. Scope & Objectives
Stream B covers the user-facing AI experience: reusable AI components, shimmer/loading indicators, memory tips in definition and grammar pages, borrowed word etymology, and interactive back-and-forth AI chat.

---

## 2. Detailed Functional Requirements

### Requirement 4 & 6: Reusable AI Components & Loading Indicators (User Tasks 4 & 6)
- The Definition page, Grammar page, and Review page currently either lack loading indicators during AI generation or have duplicated ad-hoc widgets.
- Refactor all AI presentation elements into reusable components located in `lib/common/widgets/ai/`:
  - `AiTutorCard`: displays AI tutor comments, practical nuances, usage advice, and loanword/borrowed word etymology with loading/error states.
  - `AiMemoryTipCard`: displays mnemonic tips and kanji stories for memorization.
  - `AiGrammarBreakdownCard`: displays detailed grammar and particle breakdown.
  - `AiLoadingSkeleton`: clean shimmer/pulsing skeleton shown while AI requests are in-flight.

### Requirement 5: AI Memory Tips Plugged into Definition & Grammar Pages (User Task 5)
- Display the AI-generated `memoryTip` prominently inside both `DefinitionScreen` and `GrammarPointScreen`.
- Ensure memory tips animate smoothly upon arrival and display clean empty/fallback handling when not available.

### Requirement 9: Borrowed Word Info (Etymology & Source Language Bundled into AI Comment) (User Task 9)
- Enhance `LlmService.buildWordInfoPrompt` so that for Katakana/loanwords (Gairaigo) or borrowed vocabulary, the AI tutor comment explicitly bundles origin information (source language e.g. German, Portuguese, English, French, Chinese, Sanskrit, and original word/meaning).
- No separate database column or widget is created; it is seamlessly rendered within `AiTutorCard`.

### Requirement 10: Multi-Turn Interactive AI Chat (User Task 10)
- Enable users to chat back-and-forth with the AI regarding comments, grammar rules, nuances, or confusing points.
- Provide entry point buttons ("Ask AI Tutor" / "Hỏi AI Tutor") in:
  - `DefinitionScreen`
  - `GrammarPointScreen`
  - `ReviewScreen`
- Route to `AiChatScreen` (`AppRoutes.aiChat`) preloaded with complete word context (headword, reading, JLPT, definition, current AI notes).
- Support quick follow-up prompt chips (e.g. "Explain transitive vs intransitive", "Provide 3 more conversational examples", "Clarify mnemonic").

---

## 3. Non-Functional Requirements
- **Fluid UX & No Flickering**: Maintain smooth UI transitions using cached futures/shimmer placeholders.
- **A2UI & GenUI Compatibility**: Ensure GenUI catalog and custom prompt pipelines work seamlessly.
- **TDD Requirement**: Unit tests for prompt structure, BLoC state transitions, and widget rendering.
