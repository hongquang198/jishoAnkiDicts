import '../../../localizationManager.dart';
import '../../../utils/constants.dart';
import '../../../core/data/datasources/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? dropdownValue;
  GlobalKey _toolTipGraduatingIntervalKey = GlobalKey();
  GlobalKey _toolTipStartingEaseKey = GlobalKey();
  GlobalKey _toolTipLeechThresholdKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(AppLocalizations.of(context)!.enableFloating),
                  ),
                  GestureDetector(
                    onTap: () {
                      SharedPref.prefs.getBool('enableFloating') == true
                          ? SharedPref.prefs.setBool('enableFloating', false)
                          : SharedPref.prefs.setBool('enableFloating', true);
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          SharedPref.prefs.getBool('enableFloating') == true
                              ? SharedPref.prefs
                                  .setBool('enableFloating', false)
                              : SharedPref.prefs
                                  .setBool('enableFloating', true);
                        });
                      },
                      child: SharedPref.prefs.getBool('enableFloating') == true
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Text(AppLocalizations.of(context)!.language),
                  ),
                  DropdownButton<String>(
                    value: dropdownValue,
                    hint: Text('${SharedPref.prefs.getString('language')}'),
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
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(AppLocalizations.of(context)!.newCardsPerDay)),
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: TextField(
                          onChanged: (string) {
                            SharedPref.prefs
                                .setInt('newCardsPerDay', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: SharedPref.prefs
                                .getInt('newCardsPerDay')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: [
                          Text(AppLocalizations.of(context)!.graduatingInterval),
                          GestureDetector(
                            onTap: () {
                              final dynamic _toolTip =
                                  _toolTipGraduatingIntervalKey.currentState;
                              _toolTip.ensureTooltipVisible();
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
                            SharedPref.prefs.setInt(
                                'graduatingInterval', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: SharedPref.prefs
                                .getInt('graduatingInterval')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
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
                              final dynamic _toolTip =
                                  _toolTipStartingEaseKey.currentState;
                              _toolTip.ensureTooltipVisible();
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
                            SharedPref.prefs.setDouble(
                                'startingEase', double.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: SharedPref.prefs
                                .getDouble('startingEase')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
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
                              final dynamic _toolTip =
                                  _toolTipLeechThresholdKey.currentState;
                              _toolTip.ensureTooltipVisible();
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
                            SharedPref.prefs
                                .setInt('leechThreshold', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: SharedPref.prefs
                                .getInt('leechThreshold')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
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
                            SharedPref.prefs
                                .setInt('exampleNumber', int.parse(string));
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: SharedPref.prefs
                                .getInt('exampleNumber')
                                .toString(),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

// load kanji dictionary
}
