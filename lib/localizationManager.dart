import 'utils/sharedPref.dart';
import 'package:flutter/material.dart';

class LocalizationNotifier with ChangeNotifier {
  Locale getLanguage() {
    if (SharedPref.prefs.getString('language') == 'Tiếng Việt') {
      return Locale('vi', '');
    } else {
      return Locale('en', '');
    }
  }

  void setLanguage({String language}) async {
    SharedPref.prefs.setString('language', language);
    notifyListeners();
  }
}
