import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/screens/main_screen.dart';
import 'package:JapaneseOCR/services/load_dictionary.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:float_button_overlay/float_button_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

File file;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  file = await getImageFileFromAssets('floatingicon.png');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<Dictionary> dicts;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (SharedPref.prefs.getBool('enableFloating') == true)
      setState(() {
        if (AppLifecycleState.resumed == state) {
          FloatButtonOverlay.closeOverlay;
        } else {
          FloatButtonOverlay.openOverlay(
            activityName: 'MainActivity',
            notificationText: "Floating icon",
            notificationTitle: 'JishoAnki Dictionary',
            packageName: 'com.quangpham.japaneseOCR',
            iconPath: file.path,
          );
        }
      });
  }

  Future<void> initPlatformState() async {
    try {
      FloatButtonOverlay.checkPermissions;
    } on PlatformException {}
  }

  @override
  void initState() {
    dicts = initDictionary();
    initPlatformState();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Dictionary> initDictionary() async {
    Dictionary dicts = Dictionary();
    await SharedPref.init();
    await dicts.offlineDatabase.initDatabase();
    final loadDictionary = LoadDictionary(dbManager: dicts.offlineDatabase);
    // dicts.vietnameseDictionary = await loadDictionary.loadJpvnDictionary();
    // print('Load vndict finished');
    // dicts.kanjiDictionary = await loadDictionary.loadAssetKanji();
    // print('Load kanji finished');
    // dicts.pitchAccentDict = await loadDictionary.loadPitchAccentDictionary();
    // print('Load pitch accent finished');
    // dicts.exampleDictionary = await loadDictionary.loadExampleDictionary();
    // print('Load example finished');

    dicts.history = await dicts.offlineDatabase.retrieve(tableName: 'history');
    dicts.favorite =
        await dicts.offlineDatabase.retrieve(tableName: 'favorite');
    dicts.review = await dicts.offlineDatabase.retrieve(tableName: 'review');

    return dicts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<Dictionary>(
      create: (context) async {
        return dicts;
      },
      child: FutureBuilder(
          future: SharedPref.init(),
          builder: (context, snapshot) {
            if (snapshot.data == null) return CircularProgressIndicator();
            return MaterialApp(
              title: 'JishoAnki Dictionary',
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en', ''),
                const Locale('vi', ''),
              ],
              locale: snapshot.data.getString('language') == 'Tiếng Việt'
                  ? Locale('vi', '')
                  : Locale('en', ''),
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                  color: Color(0xffDB8C8A),
                ),
                bottomSheetTheme: BottomSheetThemeData(
                  backgroundColor: Colors.white.withOpacity(0),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  backgroundColor: Color(0xffDB8C8A),
                ),
              ),
              home: MainScreen(),
            );
          }),
    );
  }
}
