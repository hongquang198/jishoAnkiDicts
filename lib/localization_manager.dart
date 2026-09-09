import 'core/data/datasources/shared_pref.dart';
import 'package:flutter/material.dart';

import 'injection.dart';

class LocalizationNotifier with ChangeNotifier {
  Locale getLanguage() {
    // Locale code is centralized in SharedPref.appLocaleCode so new languages
    // only touch that mapping plus their .arb bundle.
    return Locale(getIt<SharedPref>().appLocaleCode, '');
  }

  void setLanguage({required String language}) async {
    // The source language is the single source of truth for the app locale;
    // SharedPref.appLocaleCode derives the vi/en locale from it.
    getIt<SharedPref>().sourceLanguage = language;
    notifyListeners();
  }
}
