import 'package:get_it/get_it.dart';
import 'package:jisho_anki/core/data/datasources/shared_pref.dart';
import 'package:jisho_anki/features/main_search/data/data_sources/jisho_remote_data_source.dart';
import 'package:jisho_anki/features/main_search/domain/repositories/jisho_repository.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_for_vietnamese_definition.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_grammar_point.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/look_up_han_viet_reading.dart';
import 'package:jisho_anki/features/main_search/domain/use_cases/search_jisho_for_phrase.dart';
import 'package:jisho_anki/features/main_search/presentation/bloc/main_search_bloc.dart';
import 'package:jisho_anki/features/main_search/repository/jisho_repository_impl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/client/http_client.dart';
import 'core/services/navigation_service.dart';
import 'l10n/localization.dart';
import 'core/domain/entities/dictionary.dart';
import 'services/media_query_size.dart';

final getIt = GetIt.instance;

Future<void> inject() async {
  getIt.registerSingleton<MediaQuerySize>(MediaQuerySize());
  getIt.registerSingletonAsync<SharedPref>(() async {
    final sharedPrefsInstance = await SharedPreferences.getInstance();
    final sharedPref = SharedPref(prefs: sharedPrefsInstance);
    await sharedPref.init();
    return sharedPref;
  });
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

  // BLoC
  getIt
    ..registerFactory<MainSearchBloc>(() => MainSearchBloc(
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
    ..registerLazySingleton<LookupHanVietReading>(
        () => LookupHanVietReading())
    ..registerLazySingleton<LookUpGrammarPoint>(
        () => LookUpGrammarPoint());

  // Repository
  getIt.registerLazySingleton<JishoRepository>(() => JishoRepositoryImpl(
        jishoRemoteDataSource: getIt(),
      ));

  // getIt.registerLazySingleton<RestaurantRepository>(() => RestaurantRepositoryImpl(
  //       restaurantLocalDataSource: getIt(),
  //       restaurantRemoteDataSource: getIt(),
  //       userRemoteDataSource: getIt(),
  //     ));

  // getIt.registerLazySingleton<RestaurantTableRepository>(
  //     () => RestaurantTableRepositoryImpl(
  //           restaurantTableLocalDataSource: getIt(),
  //           restaurantTableRemoteDataSource: getIt(),
  //         ));

  // Data source
  getIt.registerLazySingleton<JishoRemoteDataSource>(
      () => JishoRemoteDataSourceImpl());
  // getIt.registerLazySingleton<RestaurantRemoteDataSource>(
  //     () => RestaurantRemoteDataSourceImpl(httpsClient: getIt()));
  // getIt.registerLazySingleton<RestaurantLocalDataSource>(
  //     () => RestaurantLocalDataSourceImpl(localStorage: getIt()));
  // getIt.registerLazySingleton<RestaurantTableLocalDataSource>(
  //     () => RestaurantTableLocalDataSourceImpl(localStorage: getIt()));
  // getIt.registerLazySingleton<RestaurantTableRemoteDataSource>(
  //     () => RestaurantTableRemoteDataSourceImpl(httpsClient: getIt()));

  // Localization without context
  getIt.registerLazySingleton<Localization>(() => Localization());
  await getIt.allReady();
}
