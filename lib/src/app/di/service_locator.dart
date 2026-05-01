import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/config/radio_browser_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/radio_browser_api_client.dart';
import '../../core/network/radio_browser_server_resolver.dart';
import '../../features/discover/data/datasources/radio_browser_remote_data_source.dart';
import '../../features/discover/data/repositories/radio_browser_station_repository.dart';
import '../../features/discover/domain/repositories/station_repository.dart';
import '../../features/discover/domain/usecases/get_genres.dart';
import '../../features/discover/domain/usecases/get_stations.dart';
import '../../features/discover/domain/usecases/get_stations_by_uuids.dart';
import '../../features/discover/domain/usecases/resolve_station_stream_url.dart';
import '../../features/discover/domain/usecases/search_stations.dart';
import '../../features/discover/presentation/cubit/discover_cubit.dart';
import '../../features/favorites/data/datasources/favorite_stations_local_data_source.dart';
import '../../features/favorites/data/models/favorite_station_hive_model.dart';
import '../../features/favorites/data/repositories/hive_favorites_repository.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/add_favorite_station.dart';
import '../../features/favorites/domain/usecases/get_favorite_stations.dart';
import '../../features/favorites/domain/usecases/is_favorite_station.dart';
import '../../features/favorites/domain/usecases/remove_favorite_station.dart';
import '../../features/favorites/domain/usecases/toggle_favorite_station.dart';
import '../../features/favorites/domain/usecases/watch_favorite_stations.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  GetIt? serviceLocator,
  Box<FavoriteStationHiveModel>? favoriteStationsBox,
}) async {
  final sl = serviceLocator ?? getIt;

  if (!sl.isRegistered<RadioBrowserConfig>()) {
    sl.registerLazySingleton<RadioBrowserConfig>(
      () => RadioBrowserConfig.production,
    );
  }

  if (!sl.isRegistered<Dio>()) {
    sl.registerLazySingleton<Dio>(() => createRadioBrowserDio(sl()));
  }

  if (!sl.isRegistered<RadioBrowserServerResolver>()) {
    sl.registerLazySingleton<RadioBrowserServerResolver>(
      () => RadioBrowserServerResolver(config: sl(), dio: sl()),
    );
  }

  if (!sl.isRegistered<RadioBrowserApiClient>()) {
    sl.registerLazySingleton<RadioBrowserApiClient>(
      () => RadioBrowserApiClient(dio: sl(), serverResolver: sl()),
    );
  }

  if (!sl.isRegistered<RadioBrowserRemoteDataSource>()) {
    sl.registerLazySingleton<RadioBrowserRemoteDataSource>(
      () => DioRadioBrowserRemoteDataSource(apiClient: sl()),
    );
  }

  if (!sl.isRegistered<StationRepository>()) {
    sl.registerLazySingleton<StationRepository>(
      () => RadioBrowserStationRepository(remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetStations>()) {
    sl.registerFactory<GetStations>(() => GetStations(sl()));
  }

  if (!sl.isRegistered<SearchStations>()) {
    sl.registerFactory<SearchStations>(() => SearchStations(sl()));
  }

  if (!sl.isRegistered<GetGenres>()) {
    sl.registerFactory<GetGenres>(() => GetGenres(sl()));
  }

  if (!sl.isRegistered<ResolveStationStreamUrl>()) {
    sl.registerFactory<ResolveStationStreamUrl>(
      () => ResolveStationStreamUrl(sl()),
    );
  }

  if (!sl.isRegistered<GetStationsByUuids>()) {
    sl.registerFactory<GetStationsByUuids>(() => GetStationsByUuids(sl()));
  }

  final favoriteBox = favoriteStationsBox ?? await _openFavoriteStationsBox();

  if (!sl.isRegistered<Box<FavoriteStationHiveModel>>()) {
    sl.registerLazySingleton<Box<FavoriteStationHiveModel>>(() => favoriteBox);
  }

  if (!sl.isRegistered<FavoriteStationsLocalDataSource>()) {
    sl.registerLazySingleton<FavoriteStationsLocalDataSource>(
      () => HiveFavoriteStationsLocalDataSource(box: sl()),
    );
  }

  if (!sl.isRegistered<FavoritesRepository>()) {
    sl.registerLazySingleton<FavoritesRepository>(
      () => HiveFavoritesRepository(localDataSource: sl()),
    );
  }

  if (!sl.isRegistered<GetFavoriteStations>()) {
    sl.registerFactory<GetFavoriteStations>(() => GetFavoriteStations(sl()));
  }

  if (!sl.isRegistered<WatchFavoriteStations>()) {
    sl.registerFactory<WatchFavoriteStations>(
      () => WatchFavoriteStations(sl()),
    );
  }

  if (!sl.isRegistered<AddFavoriteStation>()) {
    sl.registerFactory<AddFavoriteStation>(() => AddFavoriteStation(sl()));
  }

  if (!sl.isRegistered<RemoveFavoriteStation>()) {
    sl.registerFactory<RemoveFavoriteStation>(
      () => RemoveFavoriteStation(sl()),
    );
  }

  if (!sl.isRegistered<ToggleFavoriteStation>()) {
    sl.registerFactory<ToggleFavoriteStation>(
      () => ToggleFavoriteStation(sl()),
    );
  }

  if (!sl.isRegistered<IsFavoriteStation>()) {
    sl.registerFactory<IsFavoriteStation>(() => IsFavoriteStation(sl()));
  }

  if (!sl.isRegistered<DiscoverCubit>()) {
    sl.registerFactory<DiscoverCubit>(
      () => DiscoverCubit(
        getStations: sl(),
        searchStations: sl(),
        getGenres: sl(),
        watchFavoriteStations: sl(),
        toggleFavoriteStation: sl(),
      ),
    );
  }
}

Future<Box<FavoriteStationHiveModel>> _openFavoriteStationsBox() async {
  await Hive.initFlutter();
  _registerFavoriteStationAdapter();
  return Hive.openBox<FavoriteStationHiveModel>(
    HiveFavoriteStationsLocalDataSource.boxName,
  );
}

void _registerFavoriteStationAdapter() {
  const adapterTypeId = 1;
  if (!Hive.isAdapterRegistered(adapterTypeId)) {
    Hive.registerAdapter(FavoriteStationHiveModelAdapter());
  }
}
