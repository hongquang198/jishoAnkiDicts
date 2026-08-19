import 'package:flutter/material.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';

mixin class Localization {
  static late AppLocalizations _l;

  AppLocalizations get l => Localization._l;

  void init(BuildContext context) => _l = AppLocalizations.of(context)!;
}
