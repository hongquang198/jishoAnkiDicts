import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../common/widgets/nav_bar.dart';
import '../../../../injection.dart';
import '../../../../theme_manager.dart';
import '../../../../utils/constants.dart';
import '../../../../services/recognizer.dart';
import 'mixins/get_vietnamese_definition_mixin.dart';
import 'widgets/draw_screen.dart';
import 'widgets/list_search_results.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with GetVietnameseDefinitionMixin {
  late TextEditingController textEditingController;
  late Timer searchOnStoppedTyping;
  final _recognizer = Recognizer();
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";
  MainSearchBloc bloc = getIt();
  String clipboard = '';

  Future<void> _search() async {
    bloc.add(SearchForPhraseEvent(textEditingController.text));
  }

  Future _initModel({required String modelFilePath, required String labelFilePath}) async {
    await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
  }

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
        builder: (context, theme, child) => Scaffold(
              drawer: NavBar(
                textEditingController: textEditingController,
              ),
              appBar: AppBar(
                leading: Builder(
                    builder: (context) => IconButton(
                          icon: Icon(Icons.menu_rounded),
                          color: Constants.appBarIconColor,
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        )),
                title: TextField(
                  onSubmitted: (valueChanged) async {
                    await _search();
                    setState(() {});
                  },
                  style: TextStyle(color: Constants.appBarTextColor),
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Search for a word",
                    hintStyle: TextStyle(color: Constants.appBarTextColor),
                    labelStyle: TextStyle(color: Constants.appBarTextColor),
                    border: InputBorder.none,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.cancel,
                      color: Constants.appBarIconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        textEditingController.text = '';
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.brush),
                    color: Constants.appBarIconColor,
                    onPressed: () {
                      setState(() {
                        textEditingController.text = '';
                      });
                      showModalBottomSheet(
                          isScrollControlled: true,
                          enableDrag: false,
                          context: context,
                          builder: (ctx) {
                            return Wrap(children: <Widget>[
                              Container(
                                color: Color(0xFFf8f1f1),
                                height: 400,
                                child: DrawScreen(
                                    textEditingController:
                                        textEditingController),
                              ),
                            ]);
                          });
                    },
                  ),
                ],
              ),
              body: Container(
                margin: EdgeInsets.only(left: 10, top: 8.0),
                child: buildBody(),
              ),
            ));
  }

  BlocProvider<MainSearchBloc> buildBody() {
    return BlocProvider<MainSearchBloc>(
      create: (context) => bloc..add(SearchForPhraseEvent('辞書')),
      child: BlocBuilder<MainSearchBloc, MainSearchState>(
        builder: (context, state) {
          return switch (state) {
            MainSearchLoadingState() 
              => Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
            MainSearchVNLoadedState(data: var data) when data.isAppInVietnamese &&
              state.data.vnDictQuery.isNotEmpty => ListSearchResultVN(
                vnDictQuery: state.data.vnDictQuery,
              ),
            MainSearchAllLoadedState(data: var data) || MainSearchFailureState(data: var data) when data.jishoDefinitionList.isNotEmpty =>
                  ListSearchResultEN(
                    jishoDefinitionList: data.jishoDefinitionList,
                  ),
            _ => const SizedBox.shrink()
          };
        },
      ),
    );
  }
}
