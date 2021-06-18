import 'package:JapaneseOCR/screens/favoriteScreen.dart';
import 'package:JapaneseOCR/screens/grammar_screen.dart';
import 'package:JapaneseOCR/screens/historyScreen.dart';
import 'package:JapaneseOCR/screens/reviewScreen.dart';
import 'package:JapaneseOCR/screens/settingsScreen.dart';
import 'package:JapaneseOCR/screens/statisticsScreen.dart';
import 'package:JapaneseOCR/utils/sharedPref.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:JapaneseOCR/themeManager.dart';

class NavBar extends StatelessWidget {
  final TextEditingController textEditingController;
  NavBar({this.textEditingController});

  @override
  Widget build(BuildContext context) {
    // return Consumer<ThemeNotifier>(builder: (context, theme, _) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text('hongquang127@gmail.com',
                style: TextStyle(fontWeight: FontWeight.bold)),
            accountName:
                Text('My Name', style: TextStyle(fontWeight: FontWeight.bold)),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/ava.png'),
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fuji.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.search,
              color: Colors.blue,
            ),
            title: Text(AppLocalizations.of(context).lookUp),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(AppLocalizations.of(context).history),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HistoryScreen(
                            textEditingController: textEditingController,
                          )));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text(AppLocalizations.of(context).favorite),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FavoriteScreen(
                            textEditingController: textEditingController,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.alarm),
            title: Text(AppLocalizations.of(context).review),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReviewScreen(
                            textEditingController: textEditingController,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text(AppLocalizations.of(context).statistics),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StatisticsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.collections_bookmark_outlined),
            title: Text(AppLocalizations.of(context).grammar),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GrammarScreen(
                            textEditingController: textEditingController,
                          )));
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
          ListTile(
            trailing: Switch(
              value:
                  SharedPref.prefs.getString('theme') == 'dark' ? true : false,
              onChanged: (valueChanged) {
                if (valueChanged == true)
                  Provider.of<ThemeNotifier>(context, listen: false)
                      .setDarkMode();
                else
                  Provider.of<ThemeNotifier>(context, listen: false)
                      .setLightMode();
              },
            ),
            leading: Icon(Icons.nightlight_round),
            title: Text(AppLocalizations.of(context).darkMode),
          ),
        ],
      ),
    );
    // },
    // );
  }
}
