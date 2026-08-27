# Stream B Design: AI Components, UI Surfaces & AI Chat

## 1. Component Architecture & UI Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Screens & Surfaces                     │
│  (DefinitionScreen, GrammarPointScreen, ReviewScreen)       │
└──────────────┬──────────────────────────────┬───────────────┘
               │                              │
               ▼                              ▼
┌──────────────────────────────┐ ┌────────────────────────────┐
│   Reusable AI Widget Suite   │ │        AiChatScreen        │
│   • AiTutorCard              │ │  (Interactive Chat View)   │
│   • AiMemoryTipCard          │ │  • Quick prompt chips      │
│   • AiGrammarBreakdownCard   │ │  • Message bubble history  │
│   • AiLoadingSkeleton        │ │  • Streaming responses     │
└──────────────┬───────────────┘ └────────────┬───────────────┘
               │ (Prefetch Data / Cache)      │ (Chat Session)
┌──────────────▼──────────────────────────────▼───────────────┐
│                      LlmService / GenUI                     │
│  • fetchWordInfo(query) (with memoryTip & etymology bundled)│
│  • startChatSession(initialContext)                         │
│  • generateExplanationStream(query)                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Key Decisions & Rationale

> **[DECISION B1] Reusable AI Widget Suite (`lib/common/widgets/ai/`)**:
> Instead of embedding inline `Container` and text widgets directly in `definition_screen.dart`, all AI UI is extracted into dedicated stateless widgets that accept standard loading, error, and content states. This allows `ReviewScreen` to immediately reuse the same components when flipped.

> **[DECISION B2] Enhanced `fetchWordInfo` Prompt with Etymology Bundled in `tutorComment`**:
> Update `LlmService.buildWordInfoPrompt` so that `tutorComment` instructs the model:
> If the word is a loanword/borrowed word (Gairaigo) or has notable etymological origins, explicitly include the source language and original word directly in `tutorComment`.
> This avoids extra columns in the database while enriching the AI commentary.

> **[DECISION B3] `AiChatBloc` Multi-Turn Conversation**:
> Powered by `google_generative_ai`'s `ChatSession`.
> - State: `AiChatState(messages, isLoading, isStreaming, wordContext)`
> - Events: `InitializeAiChat(wordContext)`, `SendChatMessage(text)`, `SelectPromptSuggestion(chipText)`

---

## 3. UI Screen Routing Specification
- **Route**: `AppRoutes.aiChat = '/ai_chat'`
- **Arguments**:
```dart
class AiChatScreenArgs {
  final String word;
  final String? reading;
  final String? definition;
  final String? existingTutorComment;
  final String? existingMemoryTip;
  final String? grammarPoint;
  
  const AiChatScreenArgs({...});
}
```
