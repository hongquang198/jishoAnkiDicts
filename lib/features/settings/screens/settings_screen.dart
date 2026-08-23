import '../../../injection.dart';
import '../../../localization_manager.dart';
import '../../../utils/constants.dart';
import '../../../core/data/datasources/shared_pref.dart';
import '../../../services/llm_service.dart';
import '../bloc/llm_settings_bloc.dart';
import 'widgets/llm_settings_section.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jisho_anki/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? dropdownValue;
  final GlobalKey _toolTipGraduatingIntervalKey = GlobalKey();
  final GlobalKey _toolTipStartingEaseKey = GlobalKey();
  final GlobalKey _toolTipLeechThresholdKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationNotifier>(
      builder: (context, localization, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(color: Constants.appBarTextColor),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 30),
            children: [
              SizedBox(height: 15),
              // Enable Floating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(AppLocalizations.of(context)!.enableFloating),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        getIt<SharedPref>().prefs.getBool('enableFloating') ==
                                true
                            ? getIt<SharedPref>()
                                .prefs
                                .setBool('enableFloating', false)
                            : getIt<SharedPref>()
                                .prefs
                                .setBool('enableFloating', true);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child:
                          getIt<SharedPref>().prefs.getBool('enableFloating') ==
                                  true
                              ? Icon(
                                  Icons.check_box_outlined,
                                  color: Colors.blue,
                                )
                              : Icon(Icons.check_box_outline_blank_outlined,
                                  color: Colors.grey),
                    ),
                  ),
                ],
              ),
              // Language
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(AppLocalizations.of(context)!.language),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      hint: Text(
                          '${getIt<SharedPref>().prefs.getString("language")}'),
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      underline: Container(
                        height: 2,
                        color: Color(0xffDB8C8A),
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            localization.setLanguage(language: newValue);
                          });
                        }
                      },
                      items: <String>[
                        'English',
                        'Tiếng Việt',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              // New Cards Per Day
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child:
                          Text(AppLocalizations.of(context)!.newCardsPerDay)),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            getIt<SharedPref>()
                                .prefs
                                .setInt('newCardsPerDay', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: getIt<SharedPref>()
                                .prefs
                                .getInt('newCardsPerDay')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              // Graduating Interval
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(
                              AppLocalizations.of(context)!.graduatingInterval),
                          GestureDetector(
                            onTap: () {
                              final dynamic toolTip =
                                  _toolTipGraduatingIntervalKey.currentState;
                              toolTip.ensureTooltipVisible();
                            },
                            child: Tooltip(
                                key: _toolTipGraduatingIntervalKey,
                                message: AppLocalizations.of(context)!
                                    .graduatingIntervalDescription,
                                child: Icon(
                                  Icons.contact_support_outlined,
                                  size: 17,
                                )),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            getIt<SharedPref>().prefs.setInt(
                                'graduatingInterval', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: getIt<SharedPref>()
                                .prefs
                                .getInt('graduatingInterval')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              // Starting Ease
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.startingEase),
                          GestureDetector(
                            onTap: () {
                              final dynamic toolTip =
                                  _toolTipStartingEaseKey.currentState;
                              toolTip.ensureTooltipVisible();
                            },
                            child: Tooltip(
                                key: _toolTipStartingEaseKey,
                                message: AppLocalizations.of(context)!
                                    .startingEaseDescription,
                                child: Icon(
                                  Icons.contact_support_outlined,
                                  size: 17,
                                )),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            getIt<SharedPref>().prefs.setDouble(
                                'startingEase', double.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: getIt<SharedPref>()
                                .prefs
                                .getDouble('startingEase')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              // Leech Threshold
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.leechThreshold),
                          GestureDetector(
                            onTap: () {
                              final dynamic toolTip =
                                  _toolTipLeechThresholdKey.currentState;
                              toolTip.ensureTooltipVisible();
                            },
                            child: Tooltip(
                                key: _toolTipLeechThresholdKey,
                                message: AppLocalizations.of(context)!
                                    .leechThresholdDescription,
                                child: Icon(
                                  Icons.contact_support_outlined,
                                  size: 17,
                                )),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            getIt<SharedPref>()
                                .prefs
                                .setInt('leechThreshold', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: getIt<SharedPref>()
                                .prefs
                                .getInt('leechThreshold')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              // Example Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.exampleNumber),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            getIt<SharedPref>()
                                .prefs
                                .setInt('exampleNumber', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: getIt<SharedPref>()
                                .prefs
                                .getInt('exampleNumber')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              // LLM Settings Section (Bloc-powered)
              BlocProvider(
                create: (_) => LlmSettingsBloc(
                  sharedPref: getIt<SharedPref>(),
                  llmService: getIt<LlmService>(),
                ),
                child: const LlmSettingsSection(),
              ),
            ],
          ),
        );
      },
    );
  }
}

// load kanji dictionary
