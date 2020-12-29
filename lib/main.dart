import 'package:flutter/material.dart';
import 'package:JapaneseOCR/screens/draw_screen.dart';
import 'package:JapaneseOCR/models/kanji.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Japanese Handwriting Recognizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
        ),
      ),
      home: DrawScreen(),
    );
  }
}
