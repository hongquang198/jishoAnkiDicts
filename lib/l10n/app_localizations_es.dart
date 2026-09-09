// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola!';

  @override
  String get lookUp => 'Buscar';

  @override
  String get history => 'Historial';

  @override
  String get favorite => 'Favoritos';

  @override
  String get review => 'Repasar';

  @override
  String get settings => 'Ajustes';

  @override
  String get examples => 'Ejemplos';

  @override
  String get components => 'Componentes';

  @override
  String get enableFloating => 'Activar app flotante';

  @override
  String get language => 'Idioma';

  @override
  String get reviewComplete => 'Has completado tus repasos.';

  @override
  String get appTitle => 'Diccionario JishoAnki';

  @override
  String get newCardsPerDay => 'Tarjetas nuevas por día';

  @override
  String get graduatingInterval => 'Intervalo de graduación (días)';

  @override
  String get graduatingIntervalDescription =>
      'Una tarjeta recién aprendida tendrá este intervalo (días)';

  @override
  String get startingEase => 'Facilidad inicial';

  @override
  String get startingEaseDescription =>
      'El ratio que determina el próximo intervalo (nuevo intervalo = intervalo anterior × este ratio)';

  @override
  String get lapsesSteps => 'Pasos de olvido';

  @override
  String get lapsesStepsDescription =>
      'Cuando se olvida una tarjeta graduada, tendrá este intervalo';

  @override
  String get leechThreshold => 'Umbral de sanguijuela (veces)';

  @override
  String get leechThresholdDescription =>
      'Número de olvidos de una tarjeta graduada. Al llegar, la tarjeta se elimina y pasa a Favoritos';

  @override
  String get newCardsStep => 'Pasos de tarjetas nuevas';

  @override
  String get newCardsStepDescription =>
      'Las tarjetas nuevas avanzarán por estos intervalos antes de graduarse.';

  @override
  String get sentenceTranslate => 'Traducción de frases';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get exampleNumber => 'Número máximo de ejemplos';

  @override
  String get grammar => 'Gramática';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get view => 'Ver';

  @override
  String get views => 'visitas';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get tokenExpiredMessage => 'Sesión expirada';

  @override
  String get invalidRequest => 'Solicitud inválida';

  @override
  String get unauthorised => 'No autorizado';

  @override
  String get fetchDataError => 'Error al cargar datos';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get menu => 'Menú';

  @override
  String get selectLanguages => 'Elige idiomas';

  @override
  String get welcomeJishoAnki => '¡Bienvenido a Jisho Anki!';

  @override
  String get selectNativeTargetDesc =>
      'Elige tu lengua materna y el idioma que quieres aprender.';

  @override
  String get onboardingNativeLanguage => 'Lengua materna (Origen):';

  @override
  String get onboardingTargetLanguage => 'Idioma a aprender (Destino):';

  @override
  String get getStarted => 'Empezar';

  @override
  String get languageConfiguration => 'Configuración de idiomas';

  @override
  String get nativeLanguageSource => 'Lengua materna (Origen):';

  @override
  String get learningLanguageTarget => 'Idioma de aprendizaje (Destino):';

  @override
  String get aiLlmSettingsTitle => 'Ajustes de IA / LLM (Gemini)';

  @override
  String get enableAiExplanation => 'Activar explicación IA';

  @override
  String get useGenuiInterface => 'Usar interfaz GenUI';

  @override
  String get enterGeminiApiKeyHint => 'Introduce la clave API de Gemini';

  @override
  String get geminiApiKeyLabel => 'Clave API de Gemini:';

  @override
  String get llmModelNameLabel => 'Nombre del modelo (Gemini):';

  @override
  String get enterApiKeyFirst => 'Introduce primero una clave API.';

  @override
  String get fetchFromApi => 'Cargar desde la API';

  @override
  String get selectModel => 'Elegir modelo';

  @override
  String get pressFetchToLoadList =>
      'Pulsa «Cargar desde la API» para cargar la lista';

  @override
  String get customPromptTemplateLabel =>
      'Plantilla de prompt personalizada (texto):';

  @override
  String get resetToDefault => 'Restablecer';

  @override
  String get customPromptHint => 'Usa %search_words% como marcador';

  @override
  String get accountCloudSync => 'Cuenta y sincronización';

  @override
  String get accountGuest => 'Invitado (Anónimo)';

  @override
  String get accountActive => 'Cuenta en la nube activa';

  @override
  String emailLabel(String email) {
    return 'Correo: $email';
  }

  @override
  String get createAccountSync => 'Crear cuenta y sincronizar';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signinExistingAccount => 'Iniciar sesión existente';

  @override
  String get switchAccount => 'Cambiar de cuenta';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get cloudSyncSuccess =>
      '¡Sincronización completada! Datos enviados y recibidos.';

  @override
  String syncFailed(String error) {
    return 'Falló la sincronización: $error';
  }

  @override
  String get linkAccountSync => 'Vincular cuenta y sincronizar';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get enterEmailPassword => 'Introduce correo y contraseña';

  @override
  String get linkWithGoogle => 'Vincular con Google';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get linkingEmailHint =>
      'Un correo nuevo crea una cuenta · Uno existente inicia sesión';

  @override
  String get linkWithEmail => 'Vincular con correo';

  @override
  String get signinWithEmail => 'Iniciar sesión con correo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get save => 'Guardar';

  @override
  String get addToReview => 'Añadir al repaso';

  @override
  String get aiExplanation => 'Explicación IA';

  @override
  String get geminiKeyNotSet => 'Clave API de Gemini no configurada.';

  @override
  String get configureGeminiKeyDesc =>
      'Ve a Ajustes para añadir tu clave API personal de Gemini.';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get aiConnectionError => 'Error al conectar con la IA:';

  @override
  String get noOutputReceived => 'Sin respuesta.';

  @override
  String get analyzingQuery => 'Analizando vocabulario...';

  @override
  String aiExplanationTitle(String query) {
    return '✨   Explicación IA: «$query»';
  }

  @override
  String get openFullAiPage => 'Abrir página IA completa';

  @override
  String get retry => 'Reintentar';

  @override
  String get copy => 'Copiar';

  @override
  String get copiedToClipboard => '¡Copiado al portapapeles!';

  @override
  String get aiTutorInsightsSection => 'Tutor IA';

  @override
  String get aiGrammarInsightsTutor => 'Gramática IA y tutor';

  @override
  String get searchForWordHint => 'Buscar una palabra';

  @override
  String get searchHistoryHint => 'Buscar en historial...';

  @override
  String get clearHistory => 'Borrar historial';

  @override
  String get clearHistoryConfirm =>
      '¿Seguro que quieres borrar todo el historial?';

  @override
  String get clear => 'Borrar';

  @override
  String get noHistoryMatches => 'Sin coincidencias.';

  @override
  String get noHistoryYet => 'Aún no hay historial.';

  @override
  String get searchFavoritesHint => 'Buscar en favoritos...';

  @override
  String get noMatchesFound => 'Sin resultados.';

  @override
  String get noFavoritesYet => 'Aún no hay favoritos.';

  @override
  String get searchGrammarHint => 'Buscar punto gramatical';

  @override
  String get commonWordBadge => 'palabra común';

  @override
  String get deleteWordFromHistoryConfirm =>
      '¿Eliminar esta palabra del historial?';

  @override
  String get notice => 'AVISO';

  @override
  String get understood => 'Entendido';

  @override
  String reviewSessionCompletedCount(int count) {
    return '¡$count tarjetas completadas en esta sesión!';
  }

  @override
  String get removeCardFromReview => '¿Quitar esta tarjeta del mazo de repaso?';

  @override
  String get showAnswer => 'Mostrar respuesta';

  @override
  String get srsAgain => 'Otra vez';

  @override
  String get srsHard => 'Difícil';

  @override
  String get srsGood => 'Bien';

  @override
  String get srsEasy => 'Fácil';

  @override
  String get reviewBadgeNew => 'Nueva';

  @override
  String get reviewBadgeLearn => 'Aprendiendo';

  @override
  String get reviewBadgeDue => 'Vence';

  @override
  String get statisticsToday => 'Estadísticas de hoy';

  @override
  String get metricTotalDue => 'Total a repasar';

  @override
  String get metricRetention => 'Retención';

  @override
  String get metricLeechDifficult => 'Difíciles';

  @override
  String get sevenDayForecast => 'Pronóstico 7 días';

  @override
  String get dueNew => 'Nuevas';

  @override
  String get dueYoung => 'Jóvenes';

  @override
  String get dueMature => 'Maduras';

  @override
  String get dueDifficult => 'Difíciles';

  @override
  String get reviewActivity4weeks => 'Actividad de repaso (últimas 4 semanas)';

  @override
  String reviewsCountTooltip(String date, int count) {
    return '$date: $count repasos';
  }

  @override
  String get less => 'Menos';

  @override
  String get more => 'Más';

  @override
  String get noForecastData => 'Sin datos de pronóstico.';

  @override
  String cardsDueToday(int count) {
    return 'Hay $count tarjetas para hoy.';
  }

  @override
  String get aiTutorAnalyzing => 'El tutor IA está analizando las notas...';

  @override
  String get aiTutorLoadFailed => 'No se pudieron cargar los comentarios';

  @override
  String get aiTutorInsightsTitle => 'Tutor IA';

  @override
  String get noAiTutorInsights => 'Aún no hay comentarios.';

  @override
  String get noMemoryTip => 'Aún no hay truco de memoria.';

  @override
  String get memoryTipTitle => 'Truco de memoria';

  @override
  String get noGrammarBreakdown => 'Aún no hay análisis gramatical.';

  @override
  String get grammarBreakdownTitle => 'Análisis gramatical';

  @override
  String get askAiTutor => 'Preguntar al tutor';

  @override
  String get aiGeneratingInsights => 'La IA está generando comentarios...';

  @override
  String aiTutorChatTitle(String word) {
    return 'Chat IA: $word';
  }

  @override
  String chatErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get aiSuggestionNuance => 'Explicar matices y uso';

  @override
  String get aiSuggestionExamples => 'Dar 3 ejemplos de conversación';

  @override
  String get aiSuggestionMnemonic => 'Truco mnemotécnico';

  @override
  String get aiSuggestionEtymology => 'Etimología y préstamos';

  @override
  String get askAiTutorHint => 'Pregunta sobre esta palabra...';

  @override
  String get cardInfo => 'Info de tarjeta';

  @override
  String get cardInfoWord => 'Palabra';

  @override
  String get cardInfoDeck => 'Mazo';

  @override
  String get cardInfoStage => 'Etapa';

  @override
  String get cardInfoAdded => 'Añadida';

  @override
  String get cardInfoFirstReview => 'Primer repaso';

  @override
  String get cardInfoLatestReview => 'Último repaso';

  @override
  String get cardInfoDue => 'Vence';

  @override
  String get cardInfoInterval => 'Intervalo';

  @override
  String get cardInfoEaseFactor => 'Facilidad';

  @override
  String get cardInfoReviews => 'Repasos';

  @override
  String get cardInfoLapses => 'Olvidos';

  @override
  String get notAvailable => 'N/D';

  @override
  String get cardStageNew => 'Nueva';
}
