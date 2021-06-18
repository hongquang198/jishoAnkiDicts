import 'package:JapaneseOCR/themeManager.dart';
import 'package:JapaneseOCR/models/dictionary.dart';
import 'package:JapaneseOCR/screens/mainScreen.dart';
import 'package:JapaneseOCR/services/loadDictionary.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:float_button_overlay/float_button_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'localizationManager.dart';
import 'themeManager.dart';

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
  await SharedPref.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Future<Dictionary> dicts;
  // Process floating application icon when exit.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (SharedPref.prefs.getBool('enableFloating') == true) {
      if (AppLifecycleState.paused == state) {
        FloatButtonOverlay.openOverlay(
          activityName: 'MainActivity',
          notificationText: "Floating icon",
          notificationTitle: 'JishoAnki Dictionary',
          packageName: 'com.quangpham.japaneseOCR',
          iconPath: file.path,
          showTransparentCircle: true,
          iconWidth: 120,
          iconHeight: 120,
          transpCircleHeight: 130,
          transpCircleWidth: 130,
        );
      } else {
        FloatButtonOverlay.closeOverlay;
      }
    }
  }

  Future<void> initPlatformState() async {
    try {
      FloatButtonOverlay.checkPermissions;
    } on PlatformException {}
  }

  @override
  void initState() {
    dicts = initDictionary();
    // Add observer in order to use didChangeAppLifeCycle
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    // Remove observer when we don't need didChangeAppLifeCycle anymore
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Dictionary> initDictionary() async {
    Dictionary dicts = Dictionary();
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
    dicts.grammarDict =
        await dicts.offlineDatabase.retrieveJpGrammarDictionary();
    return dicts;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          FutureProvider<Dictionary>(
            create: (context) async {
              return dicts;
            },
          ),
          ChangeNotifierProvider<ThemeNotifier>(
            create: (context) => ThemeNotifier(),
          ),
          ChangeNotifierProvider<LocalizationNotifier>(
            create: (context) => LocalizationNotifier(),
          )
        ],
        builder: (context, child) {
          return FutureBuilder(
            future: SharedPref.init(),
            builder: (context, snapshot) {
              if (snapshot.data == null ||
                  Provider.of<Dictionary>(context) == null)
                return Center(child: CircularProgressIndicator());
              else
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
                  locale:
                      Provider.of<LocalizationNotifier>(context).getLanguage(),
                  theme: Provider.of<ThemeNotifier>(context).getTheme(),
                  home: MainScreen(),
                );
            },
          );
        });
  }
}
