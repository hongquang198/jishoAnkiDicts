import 'package:get_it/get_it.dart';
import 'package:japanese_ocr/core/data/datasources/sharedPref.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'core/client/http_client.dart';
import 'core/services/navigation_service.dart';
import 'l10n/localization.dart';
import 'models/dictionary.dart';

final getIt = GetIt.instance;

Future<void> inject() async {
  getIt.registerSingletonAsync<SharedPref>(SharedPref.init);
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
  // getIt
  //   ..registerFactory<ConfigCustomerSettingsBloc>(
  //     () => ConfigCustomerSettingsBloc(
  //       login: getIt(),
  //       fetchRestaurant: getIt(),
  //       fetchTable: getIt(),
  //       selectRestaurant: getIt(),
  //       selectRestaurantTable: getIt(),
  //     ),
  //   );

  // Use cases
  // getIt
  //   ..registerLazySingleton<Login>(() => Login(getIt()))
  //   ..registerLazySingleton<FetchRestaurant>(() => FetchRestaurant(getIt()))
  //   ..registerLazySingleton<FetchTable>(() => FetchTable(getIt()))
  //   ..registerLazySingleton<SelectRestaurant>(
  //       () => SelectRestaurant(restaurantRepository: getIt()))
  //   ..registerLazySingleton<SelectRestaurantTable>(
  //       () => SelectRestaurantTable(restaurantTableRepository: getIt()))
  //   ..registerLazySingleton<GetCachedSelectedRestaurant>(
  //       () => GetCachedSelectedRestaurant(getIt()))
  //   ..registerLazySingleton<GetCachedSelectedTable>(
  //       () => GetCachedSelectedTable(getIt()));

  // Repository
  // getIt.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
  //       userRemoteDataSource: getIt(),
  //       httpsClient: getIt(),
  //     ));

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
  // getIt.registerLazySingleton<UserRemoteDataSource>(
  //     () => UserRemoteDataSourceImpl(httpsClient: getIt()));
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
