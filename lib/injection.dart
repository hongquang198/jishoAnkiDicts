import 'package:get_it/get_it.dart';
import 'package:jisho_anki/core/data/datasources/firebase_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/local_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/remote_user_data_data_source.dart';
import 'package:jisho_anki/core/data/datasources/auth_remote_data_source.dart';
import 'package:jisho_anki/core/data/datasources/firebase_auth_data_source.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/core/data/datasources/user_data_migrator.dart';
import 'package:jisho_anki/core/data/datasources/user_local_data_source_impl.dart';
import 'package:jisho_anki/core/data/repositories/user_data_repository_impl.dart';
import 'package:jisho_anki/core/domain/repositories/user_data_repository.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/clear_history_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/get_favorites_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/get_history_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/get_study_stats_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/record_word_view_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/submit_review_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/toggle_favorite_use_case.dart';
import 'package:jisho_anki/core/domain/use_cases/user_data/toggle_review_use_case.dart';
import 'package:jisho_anki/features/main_search/data/data_sources/jisho_remote_data_source.dart';
import 'package:jisho_anki/features/main_search/domain/repositories/jisho_repository.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_for_vietnamese_definition.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_grammar_point.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_han_viet_reading.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/search_jisho_for_phrase.dart';
import 'package:jisho_anki/features/favorite_words/bloc/favorite_bloc.dart';
import 'package:jisho_anki/features/history/bloc/history_bloc.dart';
import 'package:jisho_anki/features/review/bloc/review_bloc.dart';
import 'package:jisho_anki/features/statistics/bloc/statistics_bloc.dart';
import 'package:jisho_anki/features/word_definition/bloc/word_interaction_bloc.dart';
import 'package:jisho_anki/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:jisho_anki/features/main_search/repository/jisho_repository_impl.dart';
import 'package:jisho_anki/services/srs_engine.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jisho_anki/core/client/http_client.dart';
import 'package:jisho_anki/core/services/navigation_service.dart';
import 'package:jisho_anki/l10n/localization.dart';
import 'package:jisho_anki/core/domain/entities/dictionary.dart';
import 'package:jisho_anki/services/llm/gen_ui_data_prefetch.dart';
import 'package:jisho_anki/services/llm/gen_ui_prefetch.dart';
import 'package:jisho_anki/services/llm_service.dart';
import 'package:jisho_anki/services/wikimedia_image_service.dart';
import 'package:jisho_anki/services/media_query_size.dart';

final getIt = GetIt.instance;

Future<void> inject() async {
  getIt.registerSingleton<MediaQuerySize>(MediaQuerySize());
  getIt.registerSingletonAsync<SharedPref>(() async {
    final sharedPrefsInstance = await SharedPreferences.getInstance();
    final sharedPref = SharedPref(prefs: sharedPrefsInstance);
    await sharedPref.init();
    return sharedPref;
  });
  getIt.registerSingletonWithDependencies<LlmService>(
      () => LlmService(sharedPref: getIt<SharedPref>()),
      dependsOn: [SharedPref]);
  getIt.registerLazySingleton<GenUiPrefetchCache>(() => GenUiPrefetchCache());
  getIt.registerLazySingleton<GenUiDataPrefetchCache>(
      () => GenUiDataPrefetchCache());
  getIt.registerLazySingleton<WikimediaImageService>(
      () => WikimediaImageService());
  getIt.registerSingletonAsync<Dictionary>(() async {
    Dictionary dicts = Dictionary();
    await dicts.offlineDatabase.initDatabase();

    dicts.history = await dicts.offlineDatabase.retrieve(tableName: 'history');
    dicts.favorite =
        await dicts.offlineDatabase.retrieve(tableName: 'favorite');
    dicts.review = await dicts.offlineDatabase.retrieve(tableName: 'review');
    dicts.grammarDict =
        await dicts.offlineDatabase.retrieveJpGrammarDictionary();
    return dicts;
  });
  getIt.registerSingletonAsync<PackageInfo>(PackageInfo.fromPlatform);
  getIt.registerSingletonWithDependencies(() => HttpsClient(),
      dependsOn: [SharedPref, PackageInfo]);
  getIt.registerLazySingleton<NavigationService>(() => NavigationServiceImpl());

  // SRS Engine
  getIt.registerLazySingleton<SrsEngine>(() {
    final prefs = getIt<SharedPref>().prefs;
    final steps = prefs
            .getStringList('newCardsSteps')
            ?.map((e) => int.tryParse(e) ?? 1)
            .toList() ??
        [1, 10];
    final gradInterval = prefs.getInt('graduatingInterval') ?? 1;
    final easyInterval = prefs.getInt('easyInterval') ?? 4;
    final easyBonus = prefs.getDouble('easyBonus') ?? 1.3;
    final intervalModifier = prefs.getDouble('intervalModifier') ?? 1.0;
    final leechThreshold = prefs.getInt('leechThreshold') ?? 8;

    return SrsEngine(
      learningStepMinutes: steps,
      graduatingIntervalDays: gradInterval,
      easyIntervalDays: easyInterval,
      easyBonus: easyBonus,
      intervalModifier: intervalModifier,
      leechThreshold: leechThreshold,
    );
  });

  // User Data Layer (Local + Pluggable Remote Backend)
  getIt.registerSingletonAsync<LocalUserDataDataSource>(() async {
    final local = UserLocalDataSourceImpl();
    await local.init();
    return local;
  });

  getIt.registerLazySingleton<RemoteUserDataDataSource>(
      () => FirebaseUserDataDataSource());

  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => FirebaseAuthDataSource());

  getIt.registerSingletonAsync<UserDataRepository>(() async {
    final repo = UserDataRepositoryImpl(
      localDataSource: getIt<LocalUserDataDataSource>(),
      remoteDataSource: getIt<RemoteUserDataDataSource>(),
      srsEngine: getIt<SrsEngine>(),
    );
    await repo.init();

    // Run one-time migration from legacy SQLite
    final migrator = UserDataMigrator(
      localDataSource: getIt<LocalUserDataDataSource>(),
      legacyDbManager: getIt<Dictionary>().offlineDatabase,
    );
    await migrator.migrateLegacyData();

    return repo;
  }, dependsOn: [LocalUserDataDataSource, Dictionary, SharedPref]);

  // User Data Use Cases
  getIt
    ..registerLazySingleton<GetFavoritesUseCase>(
        () => GetFavoritesUseCase(getIt()))
    ..registerLazySingleton<ToggleFavoriteUseCase>(
        () => ToggleFavoriteUseCase(getIt()))
    ..registerLazySingleton<ToggleReviewUseCase>(
        () => ToggleReviewUseCase(getIt()))
    ..registerLazySingleton<SubmitReviewUseCase>(
        () => SubmitReviewUseCase(getIt()))
    ..registerLazySingleton<RecordWordViewUseCase>(
        () => RecordWordViewUseCase(getIt()))
    ..registerLazySingleton<GetStudyStatsUseCase>(
        () => GetStudyStatsUseCase(getIt()))
    ..registerLazySingleton<GetHistoryUseCase>(
        () => GetHistoryUseCase(getIt()))
    ..registerLazySingleton<ClearHistoryUseCase>(
        () => ClearHistoryUseCase(getIt()));

  // BLoC
  getIt.registerFactory<WordInteractionBloc>(
      () => WordInteractionBloc(repository: getIt<UserDataRepository>()));
  getIt.registerFactory<ReviewBloc>(
      () => ReviewBloc(repository: getIt<UserDataRepository>(), srsEngine: getIt<SrsEngine>()));
  getIt.registerFactory<FavoriteBloc>(
      () => FavoriteBloc(repository: getIt<UserDataRepository>()));
  getIt.registerFactory<HistoryBloc>(
      () => HistoryBloc(repository: getIt<UserDataRepository>()));
  getIt.registerFactory<StatisticsBloc>(
      () => StatisticsBloc(repository: getIt<UserDataRepository>()));

  getIt.registerFactory<MainSearchBloc>(() => MainSearchBloc(
        lookupGrammarPoint: getIt(),
        searchJishoForPhrase: getIt(),
        lookForVietnameseDefinition: getIt(),
        lookupHanVietReading: getIt(),
      ));

  // Use cases
  getIt
    ..registerLazySingleton<SearchJishoForPhrase>(
        () => SearchJishoForPhrase(getIt()))
    ..registerLazySingleton<LookForVietnameseDefinition>(
        () => LookForVietnameseDefinition())
    ..registerLazySingleton<LookupHanVietReading>(() => LookupHanVietReading())
    ..registerLazySingleton<LookUpGrammarPoint>(() => LookUpGrammarPoint());

  // Repository
  getIt.registerLazySingleton<JishoRepository>(() => JishoRepositoryImpl(
        jishoRemoteDataSource: getIt(),
      ));

  // Data source
  getIt.registerLazySingleton<JishoRemoteDataSource>(
      () => JishoRemoteDataSourceImpl());

  // Localization without context
  getIt.registerLazySingleton<Localization>(() => Localization());
  await getIt.allReady();
}
