import 'package:float_button_overlay/float_button_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import 'config/app_routes.dart';
import 'injection.dart';
import 'theme_manager.dart';
import 'core/data/datasources/shared_pref.dart';
import 'localization_manager.dart';

Future<File> getImageFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');

  final file = File('${(await getTemporaryDirectory()).path}/$path');
  await file.writeAsBytes(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

  return file;
}

late File file;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  file = await getImageFileFromAssets('floatingicon.png');
  await inject();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // Process floating application icon when exit.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (getIt<SharedPref>().prefs.getBool('enableFloating') == true) {
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeNotifier>(
            create: (context) => ThemeNotifier(),
          ),
          ChangeNotifierProvider<LocalizationNotifier>(
            create: (context) => LocalizationNotifier(),
          )
        ],
        builder: (context, child) {
          return MaterialApp.router(
            title: 'JishoAnki Dictionary',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRoutes.routes,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Provider.of<LocalizationNotifier>(context).getLanguage(),
            theme: Provider.of<ThemeNotifier>(context).getTheme(),
          );
        });
  }
}
