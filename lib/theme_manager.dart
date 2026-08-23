import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../utils/constants.dart';
import 'core/data/datasources/shared_pref.dart';
import 'injection.dart';

class ThemeNotifier with ChangeNotifier {
  final theme = ThemeData();
  final darkTheme = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
    primarySwatch: Colors.grey,
    primaryColor: Color(0xFF212121),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(surface: const Color(0xFF212121)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Color(0xFF212121),
    ),
    dividerColor: Colors.black12,
  );

  final lightTheme = ThemeData(
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
    primaryColor: Color(0xffDB8C8A),
    primaryIconTheme: IconThemeData(color: Constants.appBarIconColor),
    primaryTextTheme: TextTheme(
      titleSmall: TextStyle(color: Constants.appBarTextColor),
      titleMedium: TextStyle(color: Constants.appBarTextColor),
      titleLarge: TextStyle(color: Constants.appBarTextColor),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xffDB8C8A),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xffDB8C8A),
    ),
  );

  ThemeData getTheme() {
    if (getIt<SharedPref>().prefs.getString('theme') == 'dark') {
      return darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.white));
    } else {
      return lightTheme;
    }
  }

  void setDarkMode() async {
    getIt<SharedPref>().prefs.setString('theme', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    getIt<SharedPref>().prefs.setString('theme', 'light');
    notifyListeners();
  }
}
