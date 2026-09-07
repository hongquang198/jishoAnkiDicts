import 'package:flutter/material.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:jisho_anki/l10n/app_localizations_en.dart';

mixin class Localization {
  static AppLocalizations _l = AppLocalizationsEn();

  AppLocalizations get l => Localization._l;

  void init(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      _l = localizations;
    }
  }
}
