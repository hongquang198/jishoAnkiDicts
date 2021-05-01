import 'package:JapaneseOCR/screens/favorite_screen.dart';
import 'package:JapaneseOCR/screens/history_screen.dart';
import 'package:JapaneseOCR/screens/review_screen.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final TextEditingController textEditingController;
  const NavBar({Key key, this.textEditingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text('hongquang127@gmail.com'),
            accountName: Text('My Name'),
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
            title: Text('Word look up'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
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
            title: Text('Favorite'),
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
            title: Text('Review'),
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
            title: Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sign out'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.color_lens),
            title: Text('Dark mode'),
          ),
        ],
      ),
    );
  }
}
