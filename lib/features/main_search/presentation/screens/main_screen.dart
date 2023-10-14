import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';

import '../../../../injection.dart';
import '../../../../theme_manager.dart';
import 'dart:async';
import '../../../../utils/constants.dart';
import '../../../../widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../services/recognizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../widgets/main_screen/draw_screen.dart';
import 'mixins/get_vietnamese_definition_mixin.dart';
import 'widgets/list_search_results.dart';

class MainScreen extends StatefulWidget {
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
  late Timer clipboardTriggerTime;
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
    textEditingController = TextEditingController();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clipboardTriggerTime =
          Timer.periodic(const Duration(milliseconds: 120), (timer) {
        try {
          Clipboard.getData('text/plain').then((clipboardContent) {
            if (clipboardContent != null) {
              if (clipboard != clipboardContent.text && clipboardContent.text != null) {
                clipboard = clipboardContent.text!;
                textEditingController.text = clipboard;
                _search();
              }
            }
          });
        } catch (e) {
          print('No clipboard data');
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    clipboardTriggerTime.cancel();
    super.dispose();
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
                title: Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: TextStyle(color: Constants.appBarTextColor),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 12.0, bottom: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextField(
                            onSubmitted: (valueChanged) async {
                              await _search();
                              setState(() {});
                            },
                            style: TextStyle(color: Constants.appBarTextColor),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                icon: Icon(Icons.search),
                                color: Constants.appBarTextColor,
                                onPressed: () async {
                                  await _search();
                                  setState(() {});
                                },
                              ),
                              suffixIcon: IconButton(
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
                              hintText: "Search for a word",
                              hintStyle:
                                  TextStyle(color: Constants.appBarTextColor),
                              labelStyle:
                                  TextStyle(color: Constants.appBarTextColor),
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
                ),
              ),
              body: Container(
                margin: EdgeInsets.all(8),
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
                textEditingController: textEditingController,
              ),
            MainSearchAllLoadedState(data: var data) || MainSearchFailureState(data: var data) when data.jishoDefinitionList.isNotEmpty =>
                  ListSearchResultEN(
                    jishoDefinitionList: data.jishoDefinitionList,
                    textEditingController: textEditingController,
                  ),
            _ => const SizedBox.shrink()
          };
        },
      ),
    );
  }
}
