import 'package:JapaneseOCR/models/jishoDefinition.dart';
import 'package:JapaneseOCR/models/kanji.dart';
import 'package:JapaneseOCR/models/definition.dart';
import 'package:JapaneseOCR/services/jisho_query.dart';

import 'package:JapaneseOCR/services/load_dictionary.dart';
import 'package:JapaneseOCR/utils/constants.dart';
import 'package:JapaneseOCR/widgets/nav_bar.dart';
import 'package:JapaneseOCR/widgets/search_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'draw_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[MainScreen(), DrawScreen()];
  final _loadDictionary = LoadDictionary();
  static List<Definition> definition = [];
  JishoQuery jishoQuery = JishoQuery();
  var jishoData;
  List<JishoDefinition> jishoDefinitionList = [];
  String keyword;
  TextEditingController _lookupWordController = TextEditingController();
  _search() {}

  @override
  void initState() {
    _initDictionary();
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void displayBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5,
            child: DrawScreen(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Color(0xff2978b5),
        title: Text(
          "Japanese Dictionary",
          style: TextStyle(color: Constants.appBarTextColor),
        ),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      style: TextStyle(color: Constants.appBarTextColor),
                      controller: _lookupWordController,
                      onChanged: (String text) async {
                        jishoDefinitionList.clear();
                        keyword = text;
                        jishoData = await jishoQuery.getJishoQuery(keyword);
                        try {
                          jishoDefinitionList =
                              await jishoQuery.getSearchResult(jishoData);
                        } catch (e) {
                          print(e);
                        }
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(Icons.search),
                          color: Constants.appBarTextColor,
                          onPressed: () async {
                            // jishoDefinitionList.clear();
                            // jishoData = await jishoQuery.getJishoQuery(keyword);
                            // jishoDefinitionList =
                            //     await jishoQuery.getSearchResult(jishoData);
                            // setState(() {});
                          },
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.cancel,
                            color: Constants.appBarIconColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _lookupWordController.text = '';
                            });
                          },
                        ),
                        hintText: "Search for a word",
                        hintStyle: TextStyle(color: Constants.appBarTextColor),
                        labelStyle: TextStyle(color: Constants.appBarTextColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.only(bottom: 10),
                  icon: Icon(Icons.brush),
                  color: Constants.appBarIconColor,
                  onPressed: () {
                    // Navigator.push(context,
                    //     MaterialPageRoute(builder: (context) => DrawScreen()));
                    displayBottomSheet(context);
                  },
                ),
              ],
            )),
      ),
      body: SearchResult(
        jishoDefinitionList: jishoDefinitionList,
      ),
    );
  }

  // load kanji dictionary
  Future _initDictionary() async {
    definition = await _loadDictionary.loadAssetDictionary();
  }
}
