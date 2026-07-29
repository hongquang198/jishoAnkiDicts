# LLM Dictionary Lookup Feature Design Specification

## Overview
This document outlines the architecture, data flow, configuration options, and maintenance guidelines for integrating an LLM (Google Gemini) into the `jishoAnkiDicts` Flutter application.

## LLM Provider & Model Selection
- **Selected Provider**: Google Gemini (`google_generative_ai` Dart SDK)
- **Default Model**: `gemini-2.0-flash`
- **Configurable Models**: Users can pick popular models (`gemini-2.0-flash`, `gemini-1.5-flash`, `gemini-1.5-flash-latest`, `gemini-1.5-pro`, `gemini-pro`) or enter custom Gemini model identifiers directly in App Settings.

## Architecture & Component Interaction

```
┌───────────────────────────────────────────────────────────┐
│                      Settings Screen                      │
│ - Toggle LLM On/Off                                       │
│ - Gemini API Key (Obscured TextField)                     │
│ - Gemini Model Identifier (Dropdown / Editable TextField) │
│ - Custom Prompt Template (%search_words%, %search_sentence%)│
└─────────────────────────────┬─────────────────────────────┘
                              │ Saves to SharedPreferences
                              ▼
┌───────────────────────────────────────────────────────────┐
│                        SharedPref                         │
│ - llmEnable: bool                                         │
│ - llmApiKey: String                                       │
│ - llmModel: String                                        │
│ - llmCustomPrompt: String                                 │
└─────────────────────────────┬─────────────────────────────┘
                              │
                              ▼
┌───────────────────────────────────────────────────────────┐
│                        LlmService                         │
│ - Formats prompt using active language & search query     │
│ - Instantiates GenerativeModel(model: sharedPref.llmModel)│
│ - Calls GenerativeModel.generateContentStream()          │
│ - Returns Stream<String>                                  │
└─────────────────────────────┬─────────────────────────────┘
                              │ Streamed text chunks
                              ▼
┌───────────────────────────────────────────────────────────┐
│                   LlmSearchResultTile                     │
│ - Expandable UI Tile at top of main search screen         │
│ - Streams text real-time via StreamBuilder                │
│ - Handles missing key, loading, success & error states    │
└───────────────────────────────────────────────────────────┘
```

## Prompt Specification & Placeholders

### Supported Variables
- `%search_words%` / `%search_sentence%`: The target word or sentence query entered by the user in the main search bar (both placeholders evaluate to the single user input string).

### Default Prompts

#### Vietnamese (Default when app language is Tiếng Việt)
> "Phân tích từ vựng và ngữ pháp cho cụm từ/câu '%search_words%' bằng Tiếng Việt. Nếu có nhiều từ (danh từ + động từ), người dùng đang tìm kiếm mẫu ngữ pháp. Trong trường hợp này, hãy hiển thị mẫu ngữ pháp và dịch nghĩa của cụm từ/câu. Nếu từ đầu tiên là động từ, hãy đưa ra ví dụ để phân biệt rõ Tự động từ (Intransitive) hay Tha động từ (Transitive). Trình bày ngắn gọn, rõ ràng, dễ đọc."

#### English (Default when app language is English)
> "Analyze the words and grammar for this lookup '%search_words%' in English. If there are multiple words (nouns+verbs), user must be definitely looking for a grammar pattern. In this case, show only the grammar pattern and the translated version of the lookup. If the first word you find is a verb, then show examples to clearly understand if the verb is Intransitive or Transitive. Keep the answer concise and easy to read."

## Configuration Keys in `SharedPreferences`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `llmEnable` | `bool` | `true` | Controls whether LLM tile is rendered in search screen |
| `llmApiKey` | `String` | `""` | User's personal Gemini API key |
| `llmModel` | `String` | `"gemini-2.0-flash"` | Gemini model identifier used for generation |
| `llmCustomPrompt` | `String` | *(Language Default)* | Customized user prompt template |

## Maintenance Guidelines
1. **Model Identifiers**: If Google updates or deprecates Gemini models, users can select or type any active Gemini model name in App Settings without code changes.
2. **Error Handling**: `LlmService` wraps API calls in try-catch to intercept `InvalidApiKeyException`, network timeouts, or model availability errors.
3. **UI Performance**: `LlmSearchResultTile` uses collapsible expansion so that LLM queries do not block standard offline dictionary lookups.
