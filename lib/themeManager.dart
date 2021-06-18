import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/material.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Color(0xFF212121),
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF212121),
    accentColor: Colors.white,
    accentIconTheme: IconThemeData(color: Color(0xFF212121)),
    dividerColor: Colors.black12,
  );

  final lightTheme =
      // ThemeData(
      //   primarySwatch: Colors.grey,
      //   primaryColor: Colors.white,
      //   brightness: Brightness.light,
      //   backgroundColor: const Color(0xFFE5E5E5),
      //   accentColor: Colors.black,
      //   accentIconTheme: IconThemeData(color: Colors.white),
      //   dividerColor: Colors.white54,
      // );
      ThemeData(
    primaryColor: Color(0xffDB8C8A),
    primaryIconTheme: IconThemeData(color: Constants.appBarIconColor),
    primaryTextTheme:
        TextTheme(title: TextStyle(color: Constants.appBarTextColor)),
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
      return darkTheme;
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
