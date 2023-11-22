import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jisho_anki/config/app_routes.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:jisho_anki/features/main_search/presentation/screens/widgets/vn_search_result_list_view.dart';
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

class MainSearchScreenConst {
  static const bodyPadding = EdgeInsets.only(
    left: 8.0,
    top: 15.0,
    right: 8.0,
  );
}

class MainSearchScreen extends StatefulWidget {
  const MainSearchScreen({super.key});

  static provider() {
    return BlocProvider<MainSearchBloc>(
      create: (context) => getIt()..add(SearchForPhraseEvent('時点')),
      child: MainSearchScreen(),
    );
  }
  @override
  _MainSearchScreenState createState() => _MainSearchScreenState();
}

class _MainSearchScreenState extends State<MainSearchScreen> with GetVietnameseDefinitionMixin, SingleTickerProviderStateMixin {
  late TextEditingController textEditingController;
  late TabController tabController;
  late FocusNode focusNode;
  late Timer searchOnStoppedTyping;
  final _recognizer = Recognizer();
  final modelFilePath1 = "assets/model806.tflite";
  final labelFilePath1 = "assets/label806.txt";
  final modelFilePath2 = "assets/model3036.tflite";
  final labelFilePath2 = "assets/label3036.txt";
  late MainSearchBloc bloc;
  String clipboard = '';
  bool keyboardListened = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    focusNode = FocusNode();
    focusNode.addListener(_onFocusChange);
    RawKeyboard.instance.addListener(_handleKeyEvent);
    bloc = context.read<MainSearchBloc>();
    textEditingController = TextEditingController();
    _initModel(modelFilePath: modelFilePath1, labelFilePath: labelFilePath1);
  }

  void _onFocusChange() {
    if (!focusNode.hasFocus) {
      textEditingController.clear();
    }
  }


  void _handleKeyEvent(RawKeyEvent event) {
    final logicalKey = event.logicalKey;
    final keyLabel = logicalKey.keyLabel;
    if (event is RawKeyDownEvent) {
      return;
    }
    
    if (keyLabel.isNotEmpty &&
        !isNumericCharacter(keyLabel) &&
        !['backspace', 'enter'].contains(keyLabel.toLowerCase()) && keyLabel.toLowerCase() != 'go back') {
      // If a key with a printable label is pressed, navigate to the search screen and update the text field.
      if (context.canPop()) {
        Navigator.of(context).popUntil(
            (route) => route.settings.name == AppRoutesPath.mainScreen);
      }
      focusNode.requestFocus();
      return;
    }
  }

  bool isNumericCharacter(String input) {
    return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].contains(int.tryParse(input));
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
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
        builder: (context, theme, child) => SafeArea(
          child: Scaffold(
                drawer: NavBar(
                  textEditingController: textEditingController,
                ),
                appBar: AppBar(
                  leading: Builder(
                      builder: (context) => IconButton(
                            icon: Icon(Icons.menu),
                            onPressed: () {
                              Scaffold.of(context).openDrawer();
                            },
                          )),
                  title: TextField(
                    focusNode: focusNode,
                    controller: textEditingController,
                    onSubmitted: (valueChanged) async {
                      await _search();
                    },
                    style: TextStyle(color: Constants.appBarTextColor),
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
                        textEditingController.clear();
                        focusNode.requestFocus();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.brush),
                      color: Constants.appBarIconColor,
                      onPressed: () {
                        textEditingController.clear();
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
                  padding: MainSearchScreenConst.bodyPadding,
                  child: const _Body(),
                ),
                bottomNavigationBar: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10.0, 4.0, 10.0, 4.0),
                    decoration: BoxDecoration(
                      color: Color(0xffDB8C8A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: TabBar(
                      controller: tabController,
                      indicatorColor: Colors.black,
                      onTap: (index) async {
                        if (index == 0) {
                          await context.pushNamed(AppRoutesPath.history);
                          tabController.animateTo(1);
                          return;
                        }
                        if (index == 1) {
                          textEditingController.clear();
                          focusNode.requestFocus();
                        }
                      },
                      tabs: const [
                        Tab(icon: Icon(Icons.history)),
                        Tab(icon: Icon(Icons.search)),
                      ],
                    ),
                  ),
                ),
              ),
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
