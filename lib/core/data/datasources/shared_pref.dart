import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  SharedPreferences prefs;
  SharedPref({required this.prefs});

  Future<void> init() async {
    List<int> newCardsSteps = [1, 10];
    List<int> lapsesSteps = [10];
    // Map<String, dynamic> values = {
    //   'newCardsSteps': newCardsSteps.map((i) => i.toString()).toList(),
    //   'newCardsOrder': 'added',
    //   'newCardsPerDay': 30,
    //   'graduatingInterval': 1,
    //   'easyInterval': 4,
    //   'startingEase': 2.5,
    //   'buryRelatedNew': true,
    //   'maximumReviews': 999,
    //   'easyBonus': 1.3,
    //   'intervalModifier': 1.0,
    //   'maximumInterval': 36500,
    //   'buryRelatedReviews': true,
    //   'lapsesSteps': lapsesSteps.map((i) => i.toString()).toList(),
    //   'lapsesNewInterval': 0.8,
    //   'minimumInterval': 1,
    //   'leechThreshold': 8,
    // };
    prefs.getStringList(_SharedPreferenceKeys.newCardsSteps) ??
        prefs.setStringList(_SharedPreferenceKeys.newCardsSteps,
            newCardsSteps.map((i) => i.toString()).toList());
    prefs.getString(_SharedPreferenceKeys.newCardsOrder) ??
        prefs.setString(
            _SharedPreferenceKeys.newCardsOrder, "added");
    prefs.getInt(_SharedPreferenceKeys.newCardsPerDay) ??
        prefs.setInt(_SharedPreferenceKeys.newCardsPerDay, 30);
    prefs.getInt(_SharedPreferenceKeys.graduatingInterval) ??
        prefs.setInt(_SharedPreferenceKeys.graduatingInterval, 1);
    prefs.getInt(_SharedPreferenceKeys.easyInterval) ??
        prefs.setInt(_SharedPreferenceKeys.easyInterval, 4);
    prefs.getDouble(_SharedPreferenceKeys.startingEase) ??
        prefs.setDouble(_SharedPreferenceKeys.startingEase, 2.5);
    prefs.getBool(_SharedPreferenceKeys.buryRelatedNew) ??
        prefs.setBool(_SharedPreferenceKeys.buryRelatedNew, true);
    prefs.getInt(_SharedPreferenceKeys.maximumReviews) ??
        prefs.setInt(_SharedPreferenceKeys.maximumReviews, 999);
    prefs.getDouble(_SharedPreferenceKeys.easyBonus) ??
        prefs.setDouble(_SharedPreferenceKeys.easyBonus, 1.3);
    prefs.getDouble(_SharedPreferenceKeys.intervalModifier) ??
        prefs.setDouble(_SharedPreferenceKeys.intervalModifier, 1.0);
    prefs.getInt(_SharedPreferenceKeys.maximumInterval) ??
        prefs.setInt(_SharedPreferenceKeys.maximumInterval, 36500);
    prefs.getBool(_SharedPreferenceKeys.buryRelatedReviews) ??
        prefs.setBool(_SharedPreferenceKeys.buryRelatedReviews, true);
    prefs.getStringList(_SharedPreferenceKeys.lapsesSteps) ??
        prefs.setStringList(_SharedPreferenceKeys.lapsesSteps,
            lapsesSteps.map((i) => i.toString()).toList());
    prefs.getDouble(_SharedPreferenceKeys.lapsesNewInterval) ??
        prefs.setDouble(_SharedPreferenceKeys.lapsesNewInterval, 0.8);
    prefs.getInt(_SharedPreferenceKeys.minimumInterval) ??
        prefs.setInt(_SharedPreferenceKeys.minimumInterval, 1);
    prefs.getInt(_SharedPreferenceKeys.leechThreshold) ??
        prefs.setInt(_SharedPreferenceKeys.leechThreshold, 8);
    prefs.getBool(_SharedPreferenceKeys.enableFloating) ??
        prefs.setBool(_SharedPreferenceKeys.enableFloating, true);
    prefs.getString(_SharedPreferenceKeys.language) ??
        prefs.setString(_SharedPreferenceKeys.language, 'English');
    prefs.getInt(_SharedPreferenceKeys.exampleNumber) ??
        prefs.setInt(_SharedPreferenceKeys.exampleNumber, 3);
    prefs.getString(_SharedPreferenceKeys.theme) ??
        prefs.setString(_SharedPreferenceKeys.theme, 'light');
    print('${prefs.getString('language')}');
  }

  bool get isAppInVietnamese => prefs.getString('language') == "Tiếng Việt";
  bool get isAppInEnglish =>
      prefs.getString('language')?.contains("English") == true;
}

class _SharedPreferenceKeys {
  static const String newCardsSteps = "newCardsSteps";
  static const String newCardsOrder = "newCardsOrder";
  static const String newCardsPerDay = "newCardsPerDay";
  static const String graduatingInterval = "graduatingInterval";
  static const String easyInterval = "easyInterval";
  static const String startingEase = "startingEase";
  static const String buryRelatedNew = "buryRelatedNew";
  static const String maximumReviews = "maximumReviews";
  static const String easyBonus = "easyBonus";
  static const String intervalModifier = "intervalModifier";
  static const String maximumInterval = "maximumInterval";
  static const String buryRelatedReviews = "buryRelatedReviews";
  static const String lapsesSteps = "lapsesSteps";
  static const String lapsesNewInterval = "lapsesNewInterval";
  static const String minimumInterval = "minimumInterval";
  static const String leechThreshold = "leechThreshold";
  static const String enableFloating = "enableFloating";
  static const String language = "language";
  static const String exampleNumber = "exampleNumber";
  static const String theme = "theme";
}
