// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get helloWorld => 'Hallo!';

  @override
  String get lookUp => 'Nachschlagen';

  @override
  String get history => 'Verlauf';

  @override
  String get favorite => 'Favoriten';

  @override
  String get review => 'Wiederholen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get examples => 'Beispiele';

  @override
  String get components => 'Komponenten';

  @override
  String get enableFloating => 'Schwebende App aktivieren';

  @override
  String get language => 'Sprache';

  @override
  String get reviewComplete => 'Du hast deine Wiederholungen abgeschlossen.';

  @override
  String get appTitle => 'JishoAnki Wörterbuch';

  @override
  String get newCardsPerDay => 'Neue Karten pro Tag';

  @override
  String get graduatingInterval => 'Abschlussintervall (Tage)';

  @override
  String get graduatingIntervalDescription =>
      'Neu gelernte Karten erhalten dieses Intervall (Tage)';

  @override
  String get startingEase => 'Start-Leichtigkeit';

  @override
  String get startingEaseDescription =>
      'Das Verhältnis, das das nächste Intervall bestimmt (neues Intervall = altes Intervall × dieses Verhältnis)';

  @override
  String get lapsesSteps => 'Vergessensschritte';

  @override
  String get lapsesStepsDescription =>
      'Wenn eine abgeschlossene Karte vergessen wird, erhält sie dieses Intervall';

  @override
  String get leechThreshold => 'Leech-Schwelle (Male)';

  @override
  String get leechThresholdDescription =>
      'Anzahl der Vergessensvorgänge. Bei Erreichen wird die Karte gelöscht und zu den Favoriten verschoben';

  @override
  String get newCardsStep => 'Schritte neuer Karten';

  @override
  String get newCardsStepDescription =>
      'Neue Karten durchlaufen diese Intervalle bis zum Abschluss.';

  @override
  String get sentenceTranslate => 'Satzübersetzung';

  @override
  String get statistics => 'Statistiken';

  @override
  String get exampleNumber => 'Maximale Beispielanzahl';

  @override
  String get grammar => 'Grammatik';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get view => 'Ansehen';

  @override
  String get views => 'Aufrufe';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get tokenExpiredMessage => 'Sitzung abgelaufen';

  @override
  String get invalidRequest => 'Ungültige Anfrage';

  @override
  String get unauthorised => 'Nicht autorisiert';

  @override
  String get fetchDataError => 'Fehler beim Laden';

  @override
  String get connectionError => 'Verbindungsfehler';

  @override
  String get menu => 'Menü';

  @override
  String get selectLanguages => 'Sprachen wählen';

  @override
  String get welcomeJishoAnki => 'Willkommen bei Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'Bitte wähle deine Muttersprache und die zu lernende Sprache.';

  @override
  String get onboardingNativeLanguage => 'Muttersprache (Source):';

  @override
  String get onboardingTargetLanguage => 'Lernsprache (Target):';

  @override
  String get getStarted => 'Los geht\'s';

  @override
  String get languageConfiguration => 'Sprachkonfiguration';

  @override
  String get nativeLanguageSource => 'Muttersprache (Source):';

  @override
  String get learningLanguageTarget => 'Lernsprache (Target):';

  @override
  String get aiLlmSettingsTitle => 'KI / LLM-Einstellungen (Gemini)';

  @override
  String get enableAiExplanation => 'KI-Erklärung aktivieren';

  @override
  String get useGenuiInterface => 'GenUI-Oberfläche verwenden';

  @override
  String get enterGeminiApiKeyHint => 'Gemini API-Key eingeben';

  @override
  String get geminiApiKeyLabel => 'Gemini API-Key:';

  @override
  String get llmModelNameLabel => 'Modellname (Gemini):';

  @override
  String get enterApiKeyFirst => 'Bitte zuerst einen API-Key eingeben.';

  @override
  String get fetchFromApi => 'Von API laden';

  @override
  String get selectModel => 'Modell wählen';

  @override
  String get pressFetchToLoadList =>
      'Drücke „Von API laden“, um die Liste zu laden';

  @override
  String get customPromptTemplateLabel =>
      'Benutzerdefinierte Prompt-Vorlage (Text):';

  @override
  String get resetToDefault => 'Zurücksetzen';

  @override
  String get customPromptHint => '%search_words% als Platzhalter verwenden';

  @override
  String get accountCloudSync => 'Konto & Cloud-Sync';

  @override
  String get accountGuest => 'Gast (Anonym)';

  @override
  String get accountActive => 'Cloud-Konto aktiv';

  @override
  String emailLabel(String email) {
    return 'E-Mail: $email';
  }

  @override
  String get createAccountSync => 'Konto erstellen & synchronisieren';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signinExistingAccount => 'Bei bestehendem Konto anmelden';

  @override
  String get switchAccount => 'Konto wechseln';

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get cloudSyncSuccess =>
      'Cloud-Sync erfolgreich! Daten gesendet & empfangen.';

  @override
  String syncFailed(String error) {
    return 'Sync fehlgeschlagen: $error';
  }

  @override
  String get linkAccountSync => 'Konto verknüpfen & synchronisieren';

  @override
  String get signIn => 'Anmelden';

  @override
  String get enterEmailPassword => 'Bitte E-Mail und Passwort eingeben';

  @override
  String get linkWithGoogle => 'Mit Google verknüpfen';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get emailAddress => 'E-Mail-Adresse';

  @override
  String get password => 'Passwort';

  @override
  String get linkingEmailHint =>
      'Neue E-Mail erstellt ein Konto · Bestehende E-Mail meldet dich an';

  @override
  String get linkWithEmail => 'Mit E-Mail verknüpfen';

  @override
  String get signinWithEmail => 'Mit E-Mail anmelden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get save => 'Speichern';

  @override
  String get addToReview => 'Zur Wiederholung hinzufügen';

  @override
  String get aiExplanation => 'KI-Erklärung';

  @override
  String get geminiKeyNotSet => 'Gemini API-Key nicht hinterlegt.';

  @override
  String get configureGeminiKeyDesc =>
      'Bitte füge in den Einstellungen deinen persönlichen Gemini API-Key hinzu.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get aiConnectionError => 'Fehler bei der KI-Verbindung:';

  @override
  String get noOutputReceived => 'Keine Antwort erhalten.';

  @override
  String get analyzingQuery => 'Analysiere Vokabeln...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   KI-Erklärung: „$query“';
  }

  @override
  String get openFullAiPage => 'Volle KI-Seite öffnen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get copy => 'Kopieren';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert!';

  @override
  String get aiTutorInsightsSection => 'KI-Tutor';

  @override
  String get aiGrammarInsightsTutor => 'KI-Grammatik & Tutor';

  @override
  String get searchForWordHint => 'Wort suchen';

  @override
  String get searchHistoryHint => 'Verlauf durchsuchen...';

  @override
  String get clearHistory => 'Verlauf löschen';

  @override
  String get clearHistoryConfirm => 'Wirklich den gesamten Verlauf löschen?';

  @override
  String get clear => 'Löschen';

  @override
  String get noHistoryMatches => 'Keine passenden Einträge.';

  @override
  String get noHistoryYet => 'Noch kein Verlauf.';

  @override
  String get searchFavoritesHint => 'Favoriten durchsuchen...';

  @override
  String get noMatchesFound => 'Keine Treffer.';

  @override
  String get noFavoritesYet => 'Noch keine Favoriten gespeichert.';

  @override
  String get searchGrammarHint => 'Grammatikpunkt suchen';

  @override
  String get commonWordBadge => 'gebräuchliches Wort';

  @override
  String get deleteWordFromHistoryConfirm =>
      'Dieses Wort aus dem Verlauf löschen?';

  @override
  String get notice => 'HINWEIS';

  @override
  String get understood => 'Verstanden';

  @override
  String reviewSessionCompletedCount(int count) {
    return '$count Karten in dieser Sitzung geschafft!';
  }

  @override
  String get removeCardFromReview =>
      'Diese Karte aus dem Wiederholungsstapel entfernen?';

  @override
  String get showAnswer => 'Antwort zeigen';

  @override
  String get srsAgain => 'Nochmal';

  @override
  String get srsHard => 'Schwer';

  @override
  String get srsGood => 'Gut';

  @override
  String get srsEasy => 'Leicht';

  @override
  String get reviewBadgeNew => 'Neu';

  @override
  String get reviewBadgeLearn => 'Lernend';

  @override
  String get reviewBadgeDue => 'Fällig';

  @override
  String get statisticsToday => 'Statistik heute';

  @override
  String get metricTotalDue => 'Fällig gesamt';

  @override
  String get metricRetention => 'Behaltensrate';

  @override
  String get metricLeechDifficult => 'Schwierig';

  @override
  String get sevenDayForecast => '7-Tage-Prognose';

  @override
  String get dueNew => 'Neu';

  @override
  String get dueYoung => 'Jung';

  @override
  String get dueMature => 'Gereift';

  @override
  String get dueDifficult => 'Schwierig';

  @override
  String get reviewActivity4weeks => 'Lernaktivität (letzte 4 Wochen)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count Wiederholungen';
  }

  @override
  String get less => 'Weniger';

  @override
  String get more => 'Mehr';

  @override
  String get noForecastData => 'Keine Prognosedaten.';

  @override
  String cardsDueToday(int count) {
    return 'Heute sind $count Karten fällig.';
  }

  @override
  String get aiTutorAnalyzing => 'KI-Tutor analysiert Wortnotizen...';

  @override
  String get aiTutorLoadFailed => 'KI-Kommentare konnten nicht geladen werden';

  @override
  String get aiTutorInsightsTitle => 'KI-Tutor';

  @override
  String get noAiTutorInsights => 'Noch keine Hinweise.';

  @override
  String get noMemoryTip => 'Noch kein Merktrick.';

  @override
  String get memoryTipTitle => 'Merktrick & Eselsbrücke';

  @override
  String get noGrammarBreakdown => 'Noch keine Grammatikanalyse.';

  @override
  String get grammarBreakdownTitle => 'Grammatik- & Strukturanalyse';

  @override
  String get askAiTutor => 'KI-Tutor fragen';

  @override
  String get aiGeneratingInsights => 'KI generiert Hinweise...';

  @override
  String aiTutorChatTitle(String word) {
    return 'KI-Tutor-Chat: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Fehler: $message';
  }

  @override
  String get aiSuggestionNuance => 'Nuancen & Gebrauch erklären';

  @override
  String get aiSuggestionExamples => '3 Gesprächsbeispiele geben';

  @override
  String get aiSuggestionMnemonic => 'Merktrick erklären';

  @override
  String get aiSuggestionEtymology => 'Etymologie & Lehnwörter';

  @override
  String get askAiTutorHint => 'Frag den KI-Tutor zu diesem Wort...';

  @override
  String get cardInfo => 'Karteninfo';

  @override
  String get cardInfoWord => 'Wort';

  @override
  String get cardInfoDeck => 'Stapel';

  @override
  String get cardInfoStage => 'Stufe';

  @override
  String get cardInfoAdded => 'Hinzugefügt';

  @override
  String get cardInfoFirstReview => 'Erste Wiederholung';

  @override
  String get cardInfoLatestReview => 'Letzte Wiederholung';

  @override
  String get cardInfoDue => 'Fällig';

  @override
  String get cardInfoInterval => 'Intervall';

  @override
  String get cardInfoEaseFactor => 'Leichtigkeitsfaktor';

  @override
  String get cardInfoReviews => 'Wiederholungen';

  @override
  String get cardInfoLapses => 'Vergessensvorgänge';

  @override
  String get notAvailable => 'k. A.';

  @override
  String get cardStageNew => 'Neu';
}
