import 'package:japanese_ocr/core/data/datasources/shared_pref.dart';
import 'package:japanese_ocr/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:japanese_ocr/features/main_search/presentation/screens/widgets/vn_search_result_list_view.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../common/widgets/nav_bar.dart';
import '../../../../injection.dart';
import '../../../../theme_manager.dart';
import '../../../../utils/constants.dart';
import '../../../../services/recognizer.dart';
import 'mixins/get_vietnamese_definition_mixin.dart';
import 'widgets/draw_screen.dart';
import 'widgets/en_search_result_list_view.dart';

class MainScreenConst {
  static const bodyPadding = EdgeInsets.only(
    left: 15.0,
    top: 15.0,
    right: 8.0,
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static provider() {
    return BlocProvider<MainSearchBloc>(
      create: (context) => getIt()..add(SearchForPhraseEvent('辞書')),
      child: MainScreen(),
    );
  }
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with GetVietnameseDefinitionMixin {
  late TextEditingController textEditingController;
  late FocusNode focusNode;
  late Timer searchOnStoppedTyping;
  final _recognizer = Recognizer();
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";
  late MainSearchBloc bloc;
  String clipboard = '';
  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    bloc = context.read<MainSearchBloc>();
    textEditingController = TextEditingController();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  Future _initModel({required String modelFilePath, required String labelFilePath}) async {
    await _recognizer.loadModel(
        modelPath: modelFilePath, labelPath: labelFilePath);
  }

  Future<void> _search() async {
    bloc.add(SearchForPhraseEvent(textEditingController.text));
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
                  focusNode: focusNode,
                  onSubmitted: (valueChanged) async {
                    await _search();
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
                      textEditingController.text = '';
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.brush),
                    color: Constants.appBarIconColor,
                    onPressed: () {
                      textEditingController.text = '';
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
              body: Padding(
                padding: MainScreenConst.bodyPadding,
                child: const _Body(),
              ),
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  focusNode.requestFocus();
              }),
            ));
  }

}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainSearchBloc, MainSearchState>(
      builder: (context, state) {
        return switch (state) {
          MainSearchLoadingState() => Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          _ => const SearchResultListView()
        };
      },
    );
  }
}

class SearchResultListView extends StatelessWidget {
  const SearchResultListView({super.key});

  @override
  Widget build(BuildContext context) {
    if (getIt<SharedPref>().isAppInVietnamese) {
      return const VnSearchResultListView();
    }
    return const EnSearchResultListView();
  }
}
