import 'package:JapaneseOCR/screens/favorite_screen.dart';
import 'package:JapaneseOCR/screens/history_screen.dart';
import 'package:JapaneseOCR/screens/review_screen.dart';
import 'package:JapaneseOCR/screens/settingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NavBar extends StatelessWidget {
  final TextEditingController textEditingController;
  const NavBar({Key key, this.textEditingController}) : super(key: key);

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
            leading: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).settings),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
