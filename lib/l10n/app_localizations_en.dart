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
}
