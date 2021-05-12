import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String dropdownValue;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settings,
          style: TextStyle(color: Constants.appBarTextColor),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context).enableFloating),
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
                          ? SharedPref.prefs.setBool('enableFloating', false)
                          : SharedPref.prefs.setBool('enableFloating', true);
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
              Text(AppLocalizations.of(context).language),
              DropdownButton<String>(
                value: dropdownValue,
                hint: Text('${SharedPref.prefs.getString('language')}'),
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                    SharedPref.prefs.setString('language', newValue);
                  });
                },
                items: <String>[
                  'English',
                  'Tiếng Việt',
                  'English and Vietnamese'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

// load kanji dictionary
}
