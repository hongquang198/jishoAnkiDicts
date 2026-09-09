// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour !';

  @override
  String get lookUp => 'Rechercher';

  @override
  String get history => 'Historique';

  @override
  String get favorite => 'Favoris';

  @override
  String get review => 'Révision';

  @override
  String get settings => 'Paramètres';

  @override
  String get examples => 'Exemples';

  @override
  String get components => 'Composants';

  @override
  String get enableFloating => 'Activer l\'application flottante';

  @override
  String get language => 'Langue';

  @override
  String get reviewComplete => 'Vous avez terminé vos révisions.';

  @override
  String get appTitle => 'Dictionnaire JishoAnki';

  @override
  String get newCardsPerDay => 'Nouvelles cartes par jour';

  @override
  String get graduatingInterval => 'Intervalle de validation (jours)';

  @override
  String get graduatingIntervalDescription =>
      'Une carte nouvellement apprise aura cet intervalle (jours)';

  @override
  String get startingEase => 'Facilité initiale';

  @override
  String get startingEaseDescription =>
      'Le ratio qui détermine le prochain intervalle (nouvel intervalle = ancien intervalle × ce ratio)';

  @override
  String get lapsesSteps => 'Étapes de rechute';

  @override
  String get lapsesStepsDescription =>
      'Lorsqu\'une carte validée est oubliée, elle aura cet intervalle';

  @override
  String get leechThreshold => 'Seuil de sangsue (fois)';

  @override
  String get leechThresholdDescription =>
      'Nombre d\'oublis d\'une carte validée. À ce nombre, la carte sera supprimée et déplacée vers les favoris';

  @override
  String get newCardsStep => 'Étapes des nouvelles cartes';

  @override
  String get newCardsStepDescription =>
      'Les nouvelles cartes progresseront par ces intervalles avant validation.';

  @override
  String get sentenceTranslate => 'Traduction de phrase';

  @override
  String get statistics => 'Statistiques';

  @override
  String get exampleNumber => 'Nombre maximal d\'exemples';

  @override
  String get grammar => 'Grammaire';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get view => 'Voir';

  @override
  String get views => 'vues';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get tokenExpiredMessage => 'Session expirée';

  @override
  String get invalidRequest => 'Requête invalide';

  @override
  String get unauthorised => 'Non autorisé';

  @override
  String get fetchDataError => 'Erreur de chargement';

  @override
  String get connectionError => 'Erreur de connexion';

  @override
  String get menu => 'Menu';

  @override
  String get selectLanguages => 'Choisir les langues';

  @override
  String get welcomeJishoAnki => 'Bienvenue sur Jisho Anki !';

  @override
  String get selectNativeTargetDesc =>
      'Veuillez choisir votre langue maternelle et la langue à apprendre.';

  @override
  String get onboardingNativeLanguage => 'Langue maternelle (Source) :';

  @override
  String get onboardingTargetLanguage => 'Langue à apprendre (Cible) :';

  @override
  String get getStarted => 'Commencer';

  @override
  String get languageConfiguration => 'Configuration des langues';

  @override
  String get nativeLanguageSource => 'Langue maternelle (Source) :';

  @override
  String get learningLanguageTarget => 'Langue apprise (Cible) :';

  @override
  String get aiLlmSettingsTitle => 'Paramètres IA / LLM (Gemini)';

  @override
  String get enableAiExplanation => 'Activer l\'explication IA';

  @override
  String get useGenuiInterface => 'Utiliser l\'interface GenUI';

  @override
  String get enterGeminiApiKeyHint => 'Saisir la clé API Gemini';

  @override
  String get geminiApiKeyLabel => 'Clé API Gemini :';

  @override
  String get llmModelNameLabel => 'Nom du modèle (Gemini) :';

  @override
  String get enterApiKeyFirst => 'Veuillez d\'abord saisir une clé API.';

  @override
  String get fetchFromApi => 'Charger depuis l\'API';

  @override
  String get selectModel => 'Choisir un modèle';

  @override
  String get pressFetchToLoadList =>
      'Appuyez sur « Charger depuis l\'API » pour charger la liste';

  @override
  String get customPromptTemplateLabel =>
      'Modèle de prompt personnalisé (texte) :';

  @override
  String get resetToDefault => 'Réinitialiser';

  @override
  String get customPromptHint => 'Utilisez %search_words% comme espace réservé';

  @override
  String get accountCloudSync => 'Compte et synchro cloud';

  @override
  String get accountGuest => 'Invité (Anonyme)';

  @override
  String get accountActive => 'Compte cloud actif';

  @override
  String emailLabel(String email) {
    return 'E-mail : $email';
  }

  @override
  String get createAccountSync => 'Créer un compte et synchroniser';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signinExistingAccount => 'Se connecter à un compte existant';

  @override
  String get switchAccount => 'Changer de compte';

  @override
  String get syncNow => 'Synchroniser';

  @override
  String get cloudSyncSuccess =>
      'Synchro cloud réussie ! Données envoyées et reçues.';

  @override
  String syncFailed(String error) {
    return 'Échec de la synchro : $error';
  }

  @override
  String get linkAccountSync => 'Lier le compte et synchroniser';

  @override
  String get signIn => 'Se connecter';

  @override
  String get enterEmailPassword =>
      'Veuillez saisir l\'e-mail et le mot de passe';

  @override
  String get linkWithGoogle => 'Lier avec Google';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get linkingEmailHint =>
      'Un nouvel e-mail crée un compte · Un e-mail existant vous connecte';

  @override
  String get linkWithEmail => 'Lier avec e-mail';

  @override
  String get signinWithEmail => 'Se connecter avec e-mail';

  @override
  String get cancel => 'Annuler';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get save => 'Enregistrer';

  @override
  String get addToReview => 'Ajouter à la révision';

  @override
  String get aiExplanation => 'Explication IA';

  @override
  String get geminiKeyNotSet => 'Clé API Gemini non configurée.';

  @override
  String get configureGeminiKeyDesc =>
      'Allez dans Paramètres pour ajouter votre clé API Gemini personnelle.';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get aiConnectionError => 'Erreur lors de la connexion à l\'IA :';

  @override
  String get noOutputReceived => 'Aucune réponse reçue.';

  @override
  String get analyzingQuery => 'Analyse du vocabulaire...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   Explication IA : « $query »';
  }

  @override
  String get openFullAiPage => 'Ouvrir la page IA complète';

  @override
  String get retry => 'Réessayer';

  @override
  String get copy => 'Copier';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers !';

  @override
  String get aiTutorInsightsSection => 'Tuteur IA';

  @override
  String get aiGrammarInsightsTutor => 'Grammaire IA et tuteur';

  @override
  String get searchForWordHint => 'Rechercher un mot';

  @override
  String get searchHistoryHint => 'Rechercher dans l\'historique...';

  @override
  String get clearHistory => 'Effacer l\'historique';

  @override
  String get clearHistoryConfirm =>
      'Voulez-vous vraiment effacer tout l\'historique ?';

  @override
  String get clear => 'Effacer';

  @override
  String get noHistoryMatches => 'Aucun historique correspondant.';

  @override
  String get noHistoryYet => 'Pas encore d\'historique.';

  @override
  String get searchFavoritesHint => 'Rechercher dans les favoris...';

  @override
  String get noMatchesFound => 'Aucun résultat.';

  @override
  String get noFavoritesYet => 'Aucun favori enregistré.';

  @override
  String get searchGrammarHint => 'Rechercher un point de grammaire';

  @override
  String get commonWordBadge => 'mot courant';

  @override
  String get deleteWordFromHistoryConfirm =>
      'Supprimer ce mot de l\'historique ?';

  @override
  String get notice => 'AVIS';

  @override
  String get understood => 'Compris';

  @override
  String reviewSessionCompletedCount(int count) {
    return '$count cartes terminées pendant cette session !';
  }

  @override
  String get removeCardFromReview =>
      'Retirer cette carte du paquet de révision ?';

  @override
  String get showAnswer => 'Voir la réponse';

  @override
  String get srsAgain => 'Encore';

  @override
  String get srsHard => 'Difficile';

  @override
  String get srsGood => 'Bien';

  @override
  String get srsEasy => 'Facile';

  @override
  String get reviewBadgeNew => 'Nouveau';

  @override
  String get reviewBadgeLearn => 'En cours';

  @override
  String get reviewBadgeDue => 'À revoir';

  @override
  String get statisticsToday => 'Statistiques du jour';

  @override
  String get metricTotalDue => 'Total à revoir';

  @override
  String get metricRetention => 'Rétention';

  @override
  String get metricLeechDifficult => 'Difficiles';

  @override
  String get sevenDayForecast => 'Prévisions 7 jours';

  @override
  String get dueNew => 'Nouveau';

  @override
  String get dueYoung => 'Jeune';

  @override
  String get dueMature => 'Mature';

  @override
  String get dueDifficult => 'Difficile';

  @override
  String get reviewActivity4weeks =>
      'Activité de révision (4 dernières semaines)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date : $count révisions';
  }

  @override
  String get less => 'Moins';

  @override
  String get more => 'Plus';

  @override
  String get noForecastData => 'Aucune donnée prévisionnelle.';

  @override
  String cardsDueToday(int count) {
    return 'Il y a $count cartes à revoir aujourd\'hui.';
  }

  @override
  String get aiTutorAnalyzing => 'Le tuteur IA analyse les notes...';

  @override
  String get aiTutorLoadFailed => 'Échec du chargement des commentaires';

  @override
  String get aiTutorInsightsTitle => 'Tuteur IA';

  @override
  String get noAiTutorInsights => 'Pas encore d\'avis.';

  @override
  String get noMemoryTip => 'Pas encore d\'astuce mémoire.';

  @override
  String get memoryTipTitle => 'Astuce mémoire';

  @override
  String get noGrammarBreakdown => 'Pas encore d\'analyse grammaticale.';

  @override
  String get grammarBreakdownTitle => 'Analyse grammaticale';

  @override
  String get askAiTutor => 'Poser une question au tuteur';

  @override
  String get aiGeneratingInsights => 'L\'IA génère des avis...';

  @override
  String aiTutorChatTitle(String word) {
    return 'Discussion IA : $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Erreur : $message';
  }

  @override
  String get aiSuggestionNuance => 'Expliquer nuance et usage';

  @override
  String get aiSuggestionExamples => 'Donner 3 exemples de conversation';

  @override
  String get aiSuggestionMnemonic => 'Astuce mnémotechnique';

  @override
  String get aiSuggestionEtymology => 'Étymologie et emprunts';

  @override
  String get askAiTutorHint => 'Posez une question sur ce mot...';

  @override
  String get cardInfo => 'Infos carte';

  @override
  String get cardInfoWord => 'Mot';

  @override
  String get cardInfoDeck => 'Paquet';

  @override
  String get cardInfoStage => 'Étape';

  @override
  String get cardInfoAdded => 'Ajoutée';

  @override
  String get cardInfoFirstReview => 'Première révision';

  @override
  String get cardInfoLatestReview => 'Dernière révision';

  @override
  String get cardInfoDue => 'Échéance';

  @override
  String get cardInfoInterval => 'Intervalle';

  @override
  String get cardInfoEaseFactor => 'Facilité';

  @override
  String get cardInfoReviews => 'Révisions';

  @override
  String get cardInfoLapses => 'Oublis';

  @override
  String get notAvailable => 'N/D';

  @override
  String get cardStageNew => 'Nouveau';
}
