import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/services/navigation_service.dart';
import '../features/card_info/screens/card_info_screen.dart';
import '../features/favorite_words/screens/favorite_screen.dart';
import '../features/grammar/screens/grammar_screen.dart';
import '../features/history/screens/saved_definition_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/main_search/presentation/screens/main_screen.dart';
import '../features/review/screens/review_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/single_grammar_point/screen/grammar_point_screen.dart';
import '../features/statistics/screens/statistics_screen.dart';
import '../features/word_definition/screens/definition_screen.dart';
import '../injection.dart';
import '../models/grammar_point.dart';
import '../models/offline_word_record.dart';

class AppRoutes {
  AppRoutes._();

  static final routes = GoRouter(
      navigatorKey: getIt<NavigationService>().navigatorKey,
      routes: <GoRoute>[
        GoRoute(
          path: '/',
          name: AppRoutesPath.mainScreen,
          builder: (context, state) => MainScreen(),
        ),
        GoRoute(
          path: AppRoutesPath.cardInfo,
          name: AppRoutesPath.cardInfo,
          builder: (_, state) => CardInfoScreen(
              offlineWordRecord: state.extra as OfflineWordRecord),
        ),
        GoRoute(
          path: AppRoutesPath.favoriteWords,
          name: AppRoutesPath.favoriteWords,
          builder: (_, state) => FavoriteScreen(
              textEditingController: state.extra as TextEditingController),
        ),
        GoRoute(
          path: AppRoutesPath.grammar,
          name: AppRoutesPath.grammar,
          builder: (_, state) => GrammarScreen(
              textEditingController: state.extra as TextEditingController),
        ),
        GoRoute(
          path: AppRoutesPath.history,
          name: AppRoutesPath.history,
          builder: (_, state) => HistoryScreen(
              textEditingController: state.extra as TextEditingController),
        ),
        GoRoute(
          path: AppRoutesPath.savedWordDefinition,
          name: AppRoutesPath.savedWordDefinition,
          builder: (_, state) => SavedDefinitionScreen(
              args: state.extra as SavedDefinitionScreenArgs),
        ),
        GoRoute(
          path: AppRoutesPath.review,
          name: AppRoutesPath.review,
          builder: (_, state) => ReviewScreen(
              textEditingController: state.extra as TextEditingController),
        ),
        GoRoute(
          path: AppRoutesPath.settings,
          name: AppRoutesPath.settings,
          builder: (_, state) => SettingsScreen(),
        ),
        GoRoute(
          path: AppRoutesPath.singleGrammarPoint,
          name: AppRoutesPath.singleGrammarPoint,
          builder: (_, state) => GrammarPointScreen(
            grammarPoint: state.extra as GrammarPoint,
          ),
        ),
        GoRoute(
          path: AppRoutesPath.statistics,
          name: AppRoutesPath.statistics,
          builder: (_, state) => StatisticsScreen(),
        ),
        GoRoute(
          path: AppRoutesPath.wordDefinition,
          name: AppRoutesPath.wordDefinition,
          builder: (_, state) =>
              DefinitionScreen.provider(args: state.extra as DefinitionScreenArgs),
        ),
      ]);
}

class AppRoutesPath {
  static const String mainScreen = '/';
  static const String cardInfo = '/card-info';
  static const String favoriteWords = '/favorite-words';
  static const String grammar = '/grammar';
  static const String history = '/history';
  static const String review = '/review';
  static const String settings = '/settings';
  static const String singleGrammarPoint = '/single-grammar-point';
  static const String statistics = '/statistics';
  static const String wordDefinition = '/word-definition';
  static const String savedWordDefinition = '/saved-word-definition';
}
