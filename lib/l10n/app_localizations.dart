import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
    Locale('vi'),
    Locale('zh')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @lookUp.
  ///
  /// In en, this message translates to:
  /// **'Look up'**
  String get lookUp;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @examples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get examples;

  /// No description provided for @components.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get components;

  /// No description provided for @enableFloating.
  ///
  /// In en, this message translates to:
  /// **'Enable floating app'**
  String get enableFloating;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @reviewComplete.
  ///
  /// In en, this message translates to:
  /// **'You have completed your reviews.'**
  String get reviewComplete;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'JishoAnki Dictionary'**
  String get appTitle;

  /// No description provided for @newCardsPerDay.
  ///
  /// In en, this message translates to:
  /// **'New cards per day'**
  String get newCardsPerDay;

  /// No description provided for @graduatingInterval.
  ///
  /// In en, this message translates to:
  /// **'Graduating interval (days)'**
  String get graduatingInterval;

  /// No description provided for @graduatingIntervalDescription.
  ///
  /// In en, this message translates to:
  /// **'Card newly graduated will have this interval (days)'**
  String get graduatingIntervalDescription;

  /// No description provided for @startingEase.
  ///
  /// In en, this message translates to:
  /// **'Starting ease ratio'**
  String get startingEase;

  /// No description provided for @startingEaseDescription.
  ///
  /// In en, this message translates to:
  /// **'The ratio which will determine how long the next interval should be (new interval = old interval * this ratio)'**
  String get startingEaseDescription;

  /// No description provided for @lapsesSteps.
  ///
  /// In en, this message translates to:
  /// **'Lapses steps'**
  String get lapsesSteps;

  /// No description provided for @lapsesStepsDescription.
  ///
  /// In en, this message translates to:
  /// **'When a graduated card is forgotten, it will have this interval'**
  String get lapsesStepsDescription;

  /// No description provided for @leechThreshold.
  ///
  /// In en, this message translates to:
  /// **'Leech threshold (times)'**
  String get leechThreshold;

  /// No description provided for @leechThresholdDescription.
  ///
  /// In en, this message translates to:
  /// **'Number of times a graduated card is forgotten. If this number is reached the card will be deleted and moved to \'Favorite\' list'**
  String get leechThresholdDescription;

  /// No description provided for @newCardsStep.
  ///
  /// In en, this message translates to:
  /// **'New cards steps'**
  String get newCardsStep;

  /// No description provided for @newCardsStepDescription.
  ///
  /// In en, this message translates to:
  /// **'New cards will progress through these interval before finally graduating.'**
  String get newCardsStepDescription;

  /// No description provided for @sentenceTranslate.
  ///
  /// In en, this message translates to:
  /// **'Sentence translate'**
  String get sentenceTranslate;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @exampleNumber.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of examples'**
  String get exampleNumber;

  /// No description provided for @grammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get grammar;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get views;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @tokenExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Token expired'**
  String get tokenExpiredMessage;

  /// No description provided for @invalidRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request'**
  String get invalidRequest;

  /// No description provided for @unauthorised.
  ///
  /// In en, this message translates to:
  /// **'Unauthorised'**
  String get unauthorised;

  /// No description provided for @fetchDataError.
  ///
  /// In en, this message translates to:
  /// **'Fetch data error'**
  String get fetchDataError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @selectLanguages.
  ///
  /// In en, this message translates to:
  /// **'Select Languages'**
  String get selectLanguages;

  /// No description provided for @welcomeJishoAnki.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Jisho Anki!'**
  String get welcomeJishoAnki;

  /// No description provided for @selectNativeTargetDesc.
  ///
  /// In en, this message translates to:
  /// **'Please select your native language and the language you want to learn.'**
  String get selectNativeTargetDesc;

  /// No description provided for @onboardingNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Native Language (Source):'**
  String get onboardingNativeLanguage;

  /// No description provided for @onboardingTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language to Learn (Target):'**
  String get onboardingTargetLanguage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @languageConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Language Configuration'**
  String get languageConfiguration;

  /// No description provided for @nativeLanguageSource.
  ///
  /// In en, this message translates to:
  /// **'Native Language (Source):'**
  String get nativeLanguageSource;

  /// No description provided for @learningLanguageTarget.
  ///
  /// In en, this message translates to:
  /// **'Learning Language (Target):'**
  String get learningLanguageTarget;

  /// No description provided for @aiLlmSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI / LLM Settings (Gemini)'**
  String get aiLlmSettingsTitle;

  /// No description provided for @enableAiExplanation.
  ///
  /// In en, this message translates to:
  /// **'Enable AI Explanation'**
  String get enableAiExplanation;

  /// No description provided for @useGenuiInterface.
  ///
  /// In en, this message translates to:
  /// **'Use GenUI Interface'**
  String get useGenuiInterface;

  /// No description provided for @enterGeminiApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Gemini API Key'**
  String get enterGeminiApiKeyHint;

  /// No description provided for @geminiApiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key:'**
  String get geminiApiKeyLabel;

  /// No description provided for @llmModelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'LLM Model Name:'**
  String get llmModelNameLabel;

  /// No description provided for @enterApiKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter an API Key first.'**
  String get enterApiKeyFirst;

  /// No description provided for @fetchFromApi.
  ///
  /// In en, this message translates to:
  /// **'Fetch from API'**
  String get fetchFromApi;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @pressFetchToLoadList.
  ///
  /// In en, this message translates to:
  /// **'Press \"Fetch from API\" to load list'**
  String get pressFetchToLoadList;

  /// No description provided for @customPromptTemplateLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom Prompt Template for text-based output:'**
  String get customPromptTemplateLabel;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default'**
  String get resetToDefault;

  /// No description provided for @customPromptHint.
  ///
  /// In en, this message translates to:
  /// **'Use %search_words% as query placeholder'**
  String get customPromptHint;

  /// No description provided for @accountCloudSync.
  ///
  /// In en, this message translates to:
  /// **'Account & Cloud Sync'**
  String get accountCloudSync;

  /// No description provided for @accountGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest User (Anonymous)'**
  String get accountGuest;

  /// No description provided for @accountActive.
  ///
  /// In en, this message translates to:
  /// **'Cloud Account Active'**
  String get accountActive;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// No description provided for @createAccountSync.
  ///
  /// In en, this message translates to:
  /// **'Create Account & Sync'**
  String get createAccountSync;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signinExistingAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Existing Account'**
  String get signinExistingAccount;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch Account'**
  String get switchAccount;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @cloudSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync completed successfully! Data pushed & pulled.'**
  String get cloudSyncSuccess;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(String error);

  /// No description provided for @linkAccountSync.
  ///
  /// In en, this message translates to:
  /// **'Link Account & Sync'**
  String get linkAccountSync;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @enterEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get enterEmailPassword;

  /// No description provided for @linkWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Link with Google'**
  String get linkWithGoogle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @linkingEmailHint.
  ///
  /// In en, this message translates to:
  /// **'New email creates a new account · Existing email signs you in'**
  String get linkingEmailHint;

  /// No description provided for @linkWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Link with Email'**
  String get linkWithEmail;

  /// No description provided for @signinWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign In with Email'**
  String get signinWithEmail;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerate;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addToReview.
  ///
  /// In en, this message translates to:
  /// **'Add to review'**
  String get addToReview;

  /// No description provided for @aiExplanation.
  ///
  /// In en, this message translates to:
  /// **'AI Explanation'**
  String get aiExplanation;

  /// No description provided for @geminiKeyNotSet.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key is not set.'**
  String get geminiKeyNotSet;

  /// No description provided for @configureGeminiKeyDesc.
  ///
  /// In en, this message translates to:
  /// **'Please go to Settings to configure your personal Gemini API Key.'**
  String get configureGeminiKeyDesc;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @aiConnectionError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while connecting to AI:'**
  String get aiConnectionError;

  /// No description provided for @noOutputReceived.
  ///
  /// In en, this message translates to:
  /// **'No output received.'**
  String get noOutputReceived;

  /// No description provided for @analyzingQuery.
  ///
  /// In en, this message translates to:
  /// **'Analyzing query...'**
  String get analyzingQuery;

  /// No description provided for @aiExplanationTitle.
  ///
  /// In en, this message translates to:
  /// **'✨   AI Explanation: \"{query}\"'**
  String aiExplanationTitle(String query);

  /// No description provided for @openFullAiPage.
  ///
  /// In en, this message translates to:
  /// **'Open full AI page'**
  String get openFullAiPage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard!'**
  String get copiedToClipboard;

  /// No description provided for @aiTutorInsightsSection.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor & Insights'**
  String get aiTutorInsightsSection;

  /// No description provided for @aiGrammarInsightsTutor.
  ///
  /// In en, this message translates to:
  /// **'AI Grammar Insights & Tutor'**
  String get aiGrammarInsightsTutor;

  /// No description provided for @searchForWordHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a word'**
  String get searchForWordHint;

  /// No description provided for @searchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search history...'**
  String get searchHistoryHint;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistory;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all lookup history?'**
  String get clearHistoryConfirm;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noHistoryMatches.
  ///
  /// In en, this message translates to:
  /// **'No history matches found.'**
  String get noHistoryMatches;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No lookup history yet.'**
  String get noHistoryYet;

  /// No description provided for @searchFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Search favorites...'**
  String get searchFavoritesHint;

  /// No description provided for @noMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'No matches found.'**
  String get noMatchesFound;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorite words saved yet.'**
  String get noFavoritesYet;

  /// No description provided for @searchGrammarHint.
  ///
  /// In en, this message translates to:
  /// **'Search grammar point'**
  String get searchGrammarHint;

  /// No description provided for @commonWordBadge.
  ///
  /// In en, this message translates to:
  /// **'common word'**
  String get commonWordBadge;

  /// No description provided for @deleteWordFromHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this word from history?'**
  String get deleteWordFromHistoryConfirm;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'NOTICE'**
  String get notice;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// No description provided for @reviewSessionCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed {count} cards in this session!'**
  String reviewSessionCompletedCount(int count);

  /// No description provided for @removeCardFromReview.
  ///
  /// In en, this message translates to:
  /// **'Remove this card from review deck?'**
  String get removeCardFromReview;

  /// No description provided for @showAnswer.
  ///
  /// In en, this message translates to:
  /// **'Show Answer'**
  String get showAnswer;

  /// No description provided for @srsAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get srsAgain;

  /// No description provided for @srsHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get srsHard;

  /// No description provided for @srsGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get srsGood;

  /// No description provided for @srsEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get srsEasy;

  /// No description provided for @reviewBadgeNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get reviewBadgeNew;

  /// No description provided for @reviewBadgeLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get reviewBadgeLearn;

  /// No description provided for @reviewBadgeDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get reviewBadgeDue;

  /// No description provided for @statisticsToday.
  ///
  /// In en, this message translates to:
  /// **'Statistics today'**
  String get statisticsToday;

  /// No description provided for @metricTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get metricTotalDue;

  /// No description provided for @metricRetention.
  ///
  /// In en, this message translates to:
  /// **'Retention'**
  String get metricRetention;

  /// No description provided for @metricLeechDifficult.
  ///
  /// In en, this message translates to:
  /// **'Leech/Difficult'**
  String get metricLeechDifficult;

  /// No description provided for @sevenDayForecast.
  ///
  /// In en, this message translates to:
  /// **'7-Day Forecast'**
  String get sevenDayForecast;

  /// No description provided for @dueNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get dueNew;

  /// No description provided for @dueYoung.
  ///
  /// In en, this message translates to:
  /// **'Young'**
  String get dueYoung;

  /// No description provided for @dueMature.
  ///
  /// In en, this message translates to:
  /// **'Mature'**
  String get dueMature;

  /// No description provided for @dueDifficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get dueDifficult;

  /// No description provided for @reviewActivity4weeks.
  ///
  /// In en, this message translates to:
  /// **'Review Activity (Past 4 Weeks)'**
  String get reviewActivity4weeks;

  /// No description provided for @reviewsCountTooltip.
  ///
  /// In en, this message translates to:
  /// **'{date}: {count} reviews'**
  String reviewsCountTooltip(String date, int count);

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get less;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noForecastData.
  ///
  /// In en, this message translates to:
  /// **'No forecast data available.'**
  String get noForecastData;

  /// No description provided for @cardsDueToday.
  ///
  /// In en, this message translates to:
  /// **'There are {count} cards due today.'**
  String cardsDueToday(int count);

  /// No description provided for @aiTutorAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor is analyzing word notes...'**
  String get aiTutorAnalyzing;

  /// No description provided for @aiTutorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load AI Tutor comments'**
  String get aiTutorLoadFailed;

  /// No description provided for @aiTutorInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Insights'**
  String get aiTutorInsightsTitle;

  /// No description provided for @noAiTutorInsights.
  ///
  /// In en, this message translates to:
  /// **'No AI Tutor insights yet.'**
  String get noAiTutorInsights;

  /// No description provided for @noMemoryTip.
  ///
  /// In en, this message translates to:
  /// **'No memory tip available yet.'**
  String get noMemoryTip;

  /// No description provided for @memoryTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Memory Tip & Mnemonic'**
  String get memoryTipTitle;

  /// No description provided for @noGrammarBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No grammar breakdown available yet.'**
  String get noGrammarBreakdown;

  /// No description provided for @grammarBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Grammar & Structure Breakdown'**
  String get grammarBreakdownTitle;

  /// No description provided for @askAiTutor.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Tutor'**
  String get askAiTutor;

  /// No description provided for @aiGeneratingInsights.
  ///
  /// In en, this message translates to:
  /// **'AI is generating insights...'**
  String get aiGeneratingInsights;

  /// No description provided for @aiTutorChatTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Chat: {word}'**
  String aiTutorChatTitle(String word);

  /// No description provided for @chatErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String chatErrorPrefix(String message);

  /// No description provided for @aiSuggestionNuance.
  ///
  /// In en, this message translates to:
  /// **'Explain nuance & usage'**
  String get aiSuggestionNuance;

  /// No description provided for @aiSuggestionExamples.
  ///
  /// In en, this message translates to:
  /// **'Provide 3 conversational examples'**
  String get aiSuggestionExamples;

  /// No description provided for @aiSuggestionMnemonic.
  ///
  /// In en, this message translates to:
  /// **'Clarify mnemonic / memory tip'**
  String get aiSuggestionMnemonic;

  /// No description provided for @aiSuggestionEtymology.
  ///
  /// In en, this message translates to:
  /// **'Etymology & loanword origin'**
  String get aiSuggestionEtymology;

  /// No description provided for @askAiTutorHint.
  ///
  /// In en, this message translates to:
  /// **'Ask AI Tutor about this word...'**
  String get askAiTutorHint;

  /// No description provided for @cardInfo.
  ///
  /// In en, this message translates to:
  /// **'Card Info'**
  String get cardInfo;

  /// No description provided for @cardInfoWord.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get cardInfoWord;

  /// No description provided for @cardInfoDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get cardInfoDeck;

  /// No description provided for @cardInfoStage.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get cardInfoStage;

  /// No description provided for @cardInfoAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get cardInfoAdded;

  /// No description provided for @cardInfoFirstReview.
  ///
  /// In en, this message translates to:
  /// **'First Review'**
  String get cardInfoFirstReview;

  /// No description provided for @cardInfoLatestReview.
  ///
  /// In en, this message translates to:
  /// **'Latest Review'**
  String get cardInfoLatestReview;

  /// No description provided for @cardInfoDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get cardInfoDue;

  /// No description provided for @cardInfoInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get cardInfoInterval;

  /// No description provided for @cardInfoEaseFactor.
  ///
  /// In en, this message translates to:
  /// **'Ease Factor'**
  String get cardInfoEaseFactor;

  /// No description provided for @cardInfoReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get cardInfoReviews;

  /// No description provided for @cardInfoLapses.
  ///
  /// In en, this message translates to:
  /// **'Lapses'**
  String get cardInfoLapses;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @cardStageNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get cardStageNew;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'id',
        'ja',
        'ko',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
