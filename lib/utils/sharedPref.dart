import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences prefs;

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
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
    prefs.getStringList('newCardsSteps') ??
        prefs.setStringList(
            'newCardsSteps', newCardsSteps.map((i) => i.toString()).toList());
    prefs.getString('newCardsOrder') ??
        prefs.setString('newCardsOrder', 'added');
    prefs.getInt('newCardsPerDay') ?? prefs.setInt('newCardsPerDay', 30);
    prefs.getInt('graduatingInterval') ?? prefs.setInt('graduatingInterval', 1);
    prefs.getInt('easyInterval') ?? prefs.setInt('easyInterval', 4);
    prefs.getDouble('startingEase') ?? prefs.setDouble('startingEase', 2.5);
    prefs.getBool('buryRelatedNew') ?? prefs.setBool('buryRelatedNew', true);
    prefs.getInt('maximumReviews') ?? prefs.setInt('maximumReviews', 999);
    prefs.getDouble('easyBonus') ?? prefs.setDouble('easyBonus', 1.3);
    prefs.getDouble('intervalModifier') ??
        prefs.setDouble('intervalModifier', 1.0);
    prefs.getInt('maximumInterval') ?? prefs.setInt('maximumInterval', 36500);
    prefs.getBool('buryRelatedReviews') ??
        prefs.setBool('buryRelatedReviews', true);
    prefs.getStringList('lapsesSteps') ??
        prefs.setStringList(
            'lapsesSteps', lapsesSteps.map((i) => i.toString()).toList());
    prefs.getDouble('lapsesNewInterval') ??
        prefs.setDouble('lapsesNewInterval', 0.8);
    prefs.getInt('minimumInterval') ?? prefs.setInt('minimumInterval', 1);
    prefs.getInt('leechThreshold') ?? prefs.setInt('leechThreshold', 8);
    prefs.getBool('enableFloating') ?? prefs.setBool('enableFloating', true);
    prefs.getString('language') ?? prefs.setString('language', 'English');
    prefs.getInt('exampleNumber') ?? prefs.setInt('exampleNumber', 3);
    prefs.getString('theme') ?? prefs.setString('theme', 'light');
    print('${prefs.getString('language')}');
    return prefs;
  }
}
