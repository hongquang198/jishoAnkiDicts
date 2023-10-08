import 'package:flutter/material.dart';
import '../utils/constants.dart';

import 'core/data/datasources/sharedPref.dart';

class ThemeNotifier with ChangeNotifier {
  final theme = ThemeData();
  final darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Color(0xFF212121),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: const Color(0xFF212121)
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      foregroundColor: Color(0xFF212121),
    ),
    dividerColor: Colors.black12,
  );

  final lightTheme = ThemeData(
    primaryColor: Color(0xffDB8C8A),
    primaryIconTheme: IconThemeData(color: Constants.appBarIconColor),
    primaryTextTheme: TextTheme(
      titleSmall: TextStyle(color: Constants.appBarTextColor),
      titleMedium: TextStyle(color: Constants.appBarTextColor),
      titleLarge: TextStyle(color: Constants.appBarTextColor),
    ),
    appBarTheme: AppBarTheme(
      color: Color(0xffDB8C8A),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white.withOpacity(0),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xffDB8C8A),
    ),
  );

  ThemeData getTheme() {
    if (SharedPref.prefs.getString('theme') == 'dark') {
      return darkTheme.copyWith(
          colorScheme: darkTheme.colorScheme.copyWith(secondary: Colors.white));
    } else {
      return lightTheme;
    }
  }

  void setDarkMode() async {
    SharedPref.prefs.setString('theme', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    SharedPref.prefs.setString('theme', 'light');
    notifyListeners();
  }
}
