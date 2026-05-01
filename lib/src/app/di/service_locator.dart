import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

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

final getIt = GetIt.instance;

Future<void> configureDependencies({GetIt? serviceLocator}) async {
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
}
