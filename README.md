# Flutter Tensorflow Lite Jisho dictionary + Ankidroid
Japanese Dictionary with Handwriting recognition using Tensorflow Lite and ETL models, jisho API
(It works on both Android and iOS.)

UI inspired by https://www.behance.net/gallery/96147213/Dictionary-app-design-concept

Since Jisho.org doesn't have a mobile application version, and most of the dictionary apps look like they're made from 2005, moreover in order to support my Vietnamese community with the latest smart features, I decided to try my best to create one using Flutter and integrated it with some basic Anki functionalities.

In short, the app aims to combine Anki with a smart dictionary to completely remove the time-consuming input process to create flashcard as fast as possible, with ample word information like pitch accent, example sentences, and a lot more!

![Nghich](https://user-images.githubusercontent.com/49474671/126075995-50a8d4c2-04ca-4e4e-aa98-03bca2a17525.png)

## Main functionality:
- **AI-powered dictionary lookup**: Integrated with Google Gemini for intelligent analysis of words, grammar patterns explanations. Thanks to customizable prompts, this feature can be adapted for other languages or study purposes beyond Japanese.
- **Interactive Multi-Turn AI Tutor Chat**: Full-screen conversational AI (`/ai_chat`) preloaded with rich word context, JLPT data, definitions, and quick suggestion chips for follow-up questions.
- **Reusable AI Component Suite & Shimmer Loading**: Polished `AiTutorCard`, `AiMemoryTipCard`, `AiGrammarBreakdownCard`, and pulsing shimmer loading skeletons (`AiLoadingSkeleton`) across Definition, Grammar, and SRS Review screens.
- **Loanword Etymology & Memory Tips**: Automatic detection of loanwords (Gairaigo) with source language origin etymology and mnemonic memory tips embedded into study cards.
- **Cloud Settings Sync & Debounced Model Discovery**: Automatic background synchronization of LLM credentials, custom prompts, and language settings to Firestore, with debounced Gemini model auto-loading upon key entry.
- **Language Onboarding & Multilingual Support**: Guided onboarding for source language (Vietnamese/English) and target learning language (Japanese), with dedicated Settings controls.
- **Generative UI (GenUI / A2UI)**: Dynamic native widget streaming and component composition for dictionary lookups.
- **Offline-First & Swappable Backend**: Clean Architecture domain abstraction with an offline-first SQLite cache (`user_data.db`) and pluggable remote backend adapters (Firebase Firestore, Supabase, or REST APIs) allowing zero-downtime backend swapping.
- **Standardized SM-2 Spaced-Repetition System (SRS)**: 4-tier grading (`Again`, `Hard`, `Good`, `Easy`), dynamic interval estimates, session queue prioritization, leech management, and instant review undo.
- **Dedicated Word View Analytics**: Independent view count tracking decoupled from SRS review attempts.
- **Study Statistics & Activity Heatmap**: Real-time due card breakdown, dynamic 7-day forecast, retention rate calculations, and a 4-week review activity heatmap.
- **Dark mode, beautiful UI**, inspired by https://www.behance.net/gallery/96147213/Dictionary-app-design-concept
- **Pitch accent dictionary** from Wadoku dictionary (> 111,000 entries).
- **Fast look up** using floating clipboard search.
- **Offline handwriting recognition**.
- **Example sentences** from tatoeba.org (> 200,000 entries).
- **Grammar look up** with corresponding JLPT level.
- **Kanji dictionary** based on RTK kanji deck with mnemonics from kanji.koohii.com (2,200 entries).
- **Dual language support** (Vietnamese and English).
- **No ads**, 100% free and open-source.

<img src="gif.gif" width="300">

And it can be installed via apk on Android: https://github.com/hongquang198/jishoAnkiDicts/releases/download/v1.0-betaEN/app-release.apk

And if you think this project is interesting, please star the GitHub page and if you think you can lend me a hand, please contact me, I would really appreciate it.

Here is the link to my reddit post for more discussions: https://www.reddit.com/r/LearnJapanese/comments/on2b6g/jishoanki_a_mobile_dictionary_application_with/

Thank you all and happy learning!

### Acknowledgements
Professor Nguyen Viet Khoa, Dean of School of Foreign Languages, Hanoi University of Science and Technology, was kind enough to send me his compilation of the Japanese-Vietnamese dictionary, so many thanks to him.
Visit his website http://nguyenvietkhoa.edu.vn/ for more info.
