import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

extension BuildContextExt on BuildContext {
  AppLocalizations get localizations {
    // if no locale was found, returns a default
    return AppLocalizations.of(this) ?? AppLocalizationsEn();
  }

  void closeKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(this);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void showSnackBar({required String content}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(content)));
  }
}
