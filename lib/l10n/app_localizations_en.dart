// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get lookUp => 'Look up';

  @override
  String get history => 'History';

  @override
  String get favorite => 'Favorite';

  @override
  String get review => 'Review';

  @override
  String get settings => 'Settings';

  @override
  String get examples => 'Examples';

  @override
  String get components => 'Components';

  @override
  String get enableFloating => 'Enable floating app';

  @override
  String get language => 'Language';

  @override
  String get reviewComplete => 'You have completed your reviews.';

  @override
  String get appTitle => 'JishoAnki Dictionary';

  @override
  String get newCardsPerDay => 'New cards per day';

  @override
  String get graduatingInterval => 'Graduating interval (days)';

  @override
  String get graduatingIntervalDescription =>
      'Card newly graduated will have this interval (days)';

  @override
  String get startingEase => 'Starting ease ratio';

  @override
  String get startingEaseDescription =>
      'The ratio which will determine how long the next interval should be (new interval = old interval * this ratio)';

  @override
  String get lapsesSteps => 'Lapses steps';

  @override
  String get lapsesStepsDescription =>
      'When a graduated card is forgotten, it will have this interval';

  @override
  String get leechThreshold => 'Leech threshold (times)';

  @override
  String get leechThresholdDescription =>
      'Number of times a graduated card is forgotten. If this number is reached the card will be deleted and moved to \'Favorite\' list';

  @override
  String get newCardsStep => 'New cards steps';

  @override
  String get newCardsStepDescription =>
      'New cards will progress through these interval before finally graduating.';

  @override
  String get sentenceTranslate => 'Sentence translate';

  @override
  String get statistics => 'Statistics';

  @override
  String get exampleNumber => 'Maximum number of examples';

  @override
  String get grammar => 'Grammar';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get view => 'View';

  @override
  String get views => 'views';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get tokenExpiredMessage => 'Token expired';

  @override
  String get invalidRequest => 'Invalid request';

  @override
  String get unauthorised => 'Unauthorised';

  @override
  String get fetchDataError => 'Fetch data error';

  @override
  String get connectionError => 'Connection error';

  @override
  String get menu => 'Menu';

  @override
  String get selectLanguages => 'Select Languages';

  @override
  String get welcomeJishoAnki => 'Welcome to Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'Please select your native language and the language you want to learn.';

  @override
  String get onboardingNativeLanguage => 'Native Language (Source):';

  @override
  String get onboardingTargetLanguage => 'Language to Learn (Target):';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageConfiguration => 'Language Configuration';

  @override
  String get nativeLanguageSource => 'Native Language (Source):';

  @override
  String get learningLanguageTarget => 'Learning Language (Target):';

  @override
  String get aiLlmSettingsTitle => 'AI / LLM Settings (Gemini)';

  @override
  String get enableAiExplanation => 'Enable AI Explanation';

  @override
  String get useGenuiInterface => 'Use GenUI Interface';

  @override
  String get enterGeminiApiKeyHint => 'Enter Gemini API Key';

  @override
  String get geminiApiKeyLabel => 'Gemini API Key:';

  @override
  String get llmModelNameLabel => 'LLM Model Name:';

  @override
  String get enterApiKeyFirst => 'Please enter an API Key first.';

  @override
  String get fetchFromApi => 'Fetch from API';

  @override
  String get selectModel => 'Select Model';

  @override
  String get pressFetchToLoadList => 'Press \"Fetch from API\" to load list';

  @override
  String get customPromptTemplateLabel =>
      'Custom Prompt Template for text-based output:';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get customPromptHint => 'Use %search_words% as query placeholder';

  @override
  String get accountCloudSync => 'Account & Cloud Sync';

  @override
  String get accountGuest => 'Guest User (Anonymous)';

  @override
  String get accountActive => 'Cloud Account Active';

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String get createAccountSync => 'Create Account & Sync';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signinExistingAccount => 'Sign In to Existing Account';

  @override
  String get switchAccount => 'Switch Account';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get cloudSyncSuccess =>
      'Cloud sync completed successfully! Data pushed & pulled.';

  @override
  String syncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get linkAccountSync => 'Link Account & Sync';

  @override
  String get signIn => 'Sign In';

  @override
  String get enterEmailPassword => 'Please enter email and password';

  @override
  String get linkWithGoogle => 'Link with Google';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get linkingEmailHint =>
      'New email creates a new account · Existing email signs you in';

  @override
  String get linkWithEmail => 'Link with Email';

  @override
  String get signinWithEmail => 'Sign In with Email';

  @override
  String get cancel => 'Cancel';

  @override
  String get regenerate => 'Regenerate';

  @override
  String get save => 'Save';

  @override
  String get addToReview => 'Add to review';

  @override
  String get aiExplanation => 'AI Explanation';

  @override
  String get geminiKeyNotSet => 'Gemini API Key is not set.';

  @override
  String get configureGeminiKeyDesc =>
      'Please go to Settings to configure your personal Gemini API Key.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get aiConnectionError => 'An error occurred while connecting to AI:';

  @override
  String get noOutputReceived => 'No output received.';

  @override
  String get analyzingQuery => 'Analyzing query...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   AI Explanation: \"$query\"';
  }

  @override
  String get openFullAiPage => 'Open full AI page';

  @override
  String get retry => 'Retry';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard!';

  @override
  String get aiTutorInsightsSection => 'AI Tutor & Insights';

  @override
  String get aiGrammarInsightsTutor => 'AI Grammar Insights & Tutor';

  @override
  String get searchForWordHint => 'Search for a word';

  @override
  String get searchHistoryHint => 'Search history...';

  @override
  String get clearHistory => 'Clear History';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all lookup history?';

  @override
  String get clear => 'Clear';

  @override
  String get noHistoryMatches => 'No history matches found.';

  @override
  String get noHistoryYet => 'No lookup history yet.';

  @override
  String get searchFavoritesHint => 'Search favorites...';

  @override
  String get noMatchesFound => 'No matches found.';

  @override
  String get noFavoritesYet => 'No favorite words saved yet.';

  @override
  String get searchGrammarHint => 'Search grammar point';

  @override
  String get commonWordBadge => 'common word';

  @override
  String get deleteWordFromHistoryConfirm => 'Delete this word from history?';

  @override
  String get notice => 'NOTICE';

  @override
  String get understood => 'Understood';

  @override
  String reviewSessionCompletedCount(int count) {
    return 'Completed $count cards in this session!';
  }

  @override
  String get removeCardFromReview => 'Remove this card from review deck?';

  @override
  String get showAnswer => 'Show Answer';

  @override
  String get srsAgain => 'Again';

  @override
  String get srsHard => 'Hard';

  @override
  String get srsGood => 'Good';

  @override
  String get srsEasy => 'Easy';

  @override
  String get reviewBadgeNew => 'New';

  @override
  String get reviewBadgeLearn => 'Learn';

  @override
  String get reviewBadgeDue => 'Due';

  @override
  String get statisticsToday => 'Statistics today';

  @override
  String get metricTotalDue => 'Total Due';

  @override
  String get metricRetention => 'Retention';

  @override
  String get metricLeechDifficult => 'Leech/Difficult';

  @override
  String get sevenDayForecast => '7-Day Forecast';

  @override
  String get dueNew => 'New';

  @override
  String get dueYoung => 'Young';

  @override
  String get dueMature => 'Mature';

  @override
  String get dueDifficult => 'Difficult';

  @override
  String get reviewActivity4weeks => 'Review Activity (Past 4 Weeks)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count reviews';
  }

  @override
  String get less => 'Less';

  @override
  String get more => 'More';

  @override
  String get noForecastData => 'No forecast data available.';

  @override
  String cardsDueToday(int count) {
    return 'There are $count cards due today.';
  }

  @override
  String get aiTutorAnalyzing => 'AI Tutor is analyzing word notes...';

  @override
  String get aiTutorLoadFailed => 'Failed to load AI Tutor comments';

  @override
  String get aiTutorInsightsTitle => 'AI Tutor Insights';

  @override
  String get noAiTutorInsights => 'No AI Tutor insights yet.';

  @override
  String get noMemoryTip => 'No memory tip available yet.';

  @override
  String get memoryTipTitle => 'Memory Tip & Mnemonic';

  @override
  String get noGrammarBreakdown => 'No grammar breakdown available yet.';

  @override
  String get grammarBreakdownTitle => 'Grammar & Structure Breakdown';

  @override
  String get askAiTutor => 'Ask AI Tutor';

  @override
  String get aiGeneratingInsights => 'AI is generating insights...';

  @override
  String aiTutorChatTitle(String word) {
    return 'AI Tutor Chat: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get aiSuggestionNuance => 'Explain nuance & usage';

  @override
  String get aiSuggestionExamples => 'Provide 3 conversational examples';

  @override
  String get aiSuggestionMnemonic => 'Clarify mnemonic / memory tip';

  @override
  String get aiSuggestionEtymology => 'Etymology & loanword origin';

  @override
  String get askAiTutorHint => 'Ask AI Tutor about this word...';

  @override
  String get cardInfo => 'Card Info';

  @override
  String get cardInfoWord => 'Word';

  @override
  String get cardInfoDeck => 'Deck';

  @override
  String get cardInfoStage => 'Stage';

  @override
  String get cardInfoAdded => 'Added';

  @override
  String get cardInfoFirstReview => 'First Review';

  @override
  String get cardInfoLatestReview => 'Latest Review';

  @override
  String get cardInfoDue => 'Due';

  @override
  String get cardInfoInterval => 'Interval';

  @override
  String get cardInfoEaseFactor => 'Ease Factor';

  @override
  String get cardInfoReviews => 'Reviews';

  @override
  String get cardInfoLapses => 'Lapses';

  @override
  String get notAvailable => 'N/A';

  @override
  String get cardStageNew => 'New';
}
