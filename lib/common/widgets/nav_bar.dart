import 'package:go_router/go_router.dart';
import 'package:jisho_anki/config/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../core/data/datasources/shared_pref.dart';
import '../../injection.dart';
import '../../theme_manager.dart';

class NavBar extends StatelessWidget {
  final TextEditingController textEditingController;
  NavBar({required this.textEditingController});

  @override
  Widget build(BuildContext context) {
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
            title: Text(AppLocalizations.of(context)!.lookUp),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text(AppLocalizations.of(context)!.history),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.history);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.bookmark,
              color: Colors.red,
            ),
            title: Text(AppLocalizations.of(context)!.favorite),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.favoriteWords);
            },
          ),
          ListTile(
            leading: Icon(Icons.alarm),
            title: Text(AppLocalizations.of(context)!.review),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.review);
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text(AppLocalizations.of(context)!.statistics),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.statistics);
            },
          ),
          ListTile(
            leading: Icon(Icons.collections_bookmark_outlined),
            title: Text(AppLocalizations.of(context)!.grammar),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.grammar);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context)!.settings),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(AppRoutesPath.settings);
            },
          ),
          ListTile(
            trailing: Switch(
              value:
                  getIt<SharedPref>().prefs.getString('theme') == 'dark' ? true : false,
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
            title: Text(AppLocalizations.of(context)!.darkMode),
          ),
        ],
      ),
    );
    // },
    // );
  }
}
