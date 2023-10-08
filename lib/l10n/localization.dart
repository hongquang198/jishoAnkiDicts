import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Localization {
  static late AppLocalizations _l;

  AppLocalizations get l => Localization._l;

  void init(BuildContext context) => _l = AppLocalizations.of(context)!;
}
