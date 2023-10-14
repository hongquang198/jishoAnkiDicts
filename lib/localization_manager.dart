import 'core/data/datasources/shared_pref.dart';
import 'package:flutter/material.dart';

import 'injection.dart';

class LocalizationNotifier with ChangeNotifier {
  Locale getLanguage() {
    if (getIt<SharedPref>().prefs.getString('language') == 'Tiếng Việt') {
      return Locale('vi', '');
    } else {
      return Locale('en', '');
    }
  }

  void setLanguage({required String language}) async {
    getIt<SharedPref>().prefs.setString('language', language);
    notifyListeners();
  }
}
