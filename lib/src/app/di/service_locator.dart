import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';

import '../../core/config/open_ai_config.dart';
import '../../core/config/radio_browser_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/open_ai_dio_client.dart';
import '../../core/network/radio_browser_api_client.dart';
import '../../core/network/radio_browser_server_resolver.dart';
import '../../features/ai_finder/data/datasources/open_ai_remote_data_source.dart';
import '../../features/ai_finder/data/repositories/open_ai_station_ai_repository.dart';
import '../../features/ai_finder/data/repositories/record_voice_search_recorder_repository.dart';
import '../../features/ai_finder/domain/repositories/station_ai_repository.dart';
import '../../features/ai_finder/domain/repositories/voice_search_recorder_repository.dart';
import '../../features/ai_finder/domain/usecases/rank_stations_with_ai.dart';
import '../../features/ai_finder/domain/usecases/start_voice_search_recording.dart';
import '../../features/ai_finder/domain/usecases/stop_voice_search_recording.dart';
import '../../features/ai_finder/domain/usecases/transcribe_station_search.dart';
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
import '../../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../../features/player/data/repositories/just_audio_radio_player_repository.dart';
import '../../features/player/domain/repositories/radio_player_repository.dart';
import '../../features/player/domain/usecases/pause_radio_station.dart';
import '../../features/player/domain/usecases/play_radio_station.dart';
import '../../features/player/domain/usecases/resume_radio_station.dart';
import '../../features/player/domain/usecases/set_radio_volume.dart';
import '../../features/player/domain/usecases/stop_radio_station.dart';
import '../../features/player/domain/usecases/watch_radio_playback.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({
  GetIt? serviceLocator,
  Box<FavoriteStationHiveModel>? favoriteStationsBox,
  RadioPlayerRepository? radioPlayerRepository,
  StationAiRepository? stationAiRepository,
  VoiceSearchRecorderRepository? voiceSearchRecorderRepository,
}) async {
  final sl = serviceLocator ?? getIt;

  if (!sl.isRegistered<RadioBrowserConfig>()) {
    sl.registerLazySingleton<RadioBrowserConfig>(
      () => RadioBrowserConfig.production,
    );
  }

  if (!sl.isRegistered<OpenAiConfig>()) {
    sl.registerLazySingleton<OpenAiConfig>(() => OpenAiConfig.production);
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

  if (!sl.isRegistered<OpenAiRemoteDataSource>()) {
    sl.registerLazySingleton<OpenAiRemoteDataSource>(
      () => DioOpenAiRemoteDataSource(dio: createOpenAiDio(sl()), config: sl()),
    );
  }

  if (stationAiRepository != null && !sl.isRegistered<StationAiRepository>()) {
    sl.registerLazySingleton<StationAiRepository>(() => stationAiRepository);
  }

  if (!sl.isRegistered<StationAiRepository>()) {
    sl.registerLazySingleton<StationAiRepository>(
      () => OpenAiStationAiRepository(config: sl(), remoteDataSource: sl()),
    );
  }

  if (!sl.isRegistered<RankStationsWithAi>()) {
    sl.registerFactory<RankStationsWithAi>(() => RankStationsWithAi(sl()));
  }

  if (!sl.isRegistered<TranscribeStationSearch>()) {
    sl.registerFactory<TranscribeStationSearch>(
      () => TranscribeStationSearch(sl()),
    );
  }

  if (voiceSearchRecorderRepository != null &&
      !sl.isRegistered<VoiceSearchRecorderRepository>()) {
    sl.registerLazySingleton<VoiceSearchRecorderRepository>(
      () => voiceSearchRecorderRepository,
    );
  }

  if (!sl.isRegistered<VoiceSearchRecorderRepository>()) {
    sl.registerLazySingleton<VoiceSearchRecorderRepository>(
      RecordVoiceSearchRecorderRepository.new,
      dispose: (repository) => repository.dispose(),
    );
  }

  if (!sl.isRegistered<StartVoiceSearchRecording>()) {
    sl.registerFactory<StartVoiceSearchRecording>(
      () => StartVoiceSearchRecording(sl()),
    );
  }

  if (!sl.isRegistered<StopVoiceSearchRecording>()) {
    sl.registerFactory<StopVoiceSearchRecording>(
      () => StopVoiceSearchRecording(sl()),
    );
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

  if (radioPlayerRepository != null &&
      !sl.isRegistered<RadioPlayerRepository>()) {
    sl.registerLazySingleton<RadioPlayerRepository>(
      () => radioPlayerRepository,
    );
  }

  if (!sl.isRegistered<RadioPlayerRepository>()) {
    if (!sl.isRegistered<AudioPlayer>()) {
      sl.registerLazySingleton<AudioPlayer>(AudioPlayer.new);
    }

    sl.registerLazySingleton<RadioPlayerRepository>(
      () => JustAudioRadioPlayerRepository(audioPlayer: sl()),
      dispose: (repository) => repository.dispose(),
    );
  }

  if (!sl.isRegistered<PlayRadioStation>()) {
    sl.registerFactory<PlayRadioStation>(
      () => PlayRadioStation(
        resolveStationStreamUrl: sl(),
        radioPlayerRepository: sl(),
      ),
    );
  }

  if (!sl.isRegistered<PauseRadioStation>()) {
    sl.registerFactory<PauseRadioStation>(() => PauseRadioStation(sl()));
  }

  if (!sl.isRegistered<ResumeRadioStation>()) {
    sl.registerFactory<ResumeRadioStation>(() => ResumeRadioStation(sl()));
  }

  if (!sl.isRegistered<SetRadioVolume>()) {
    sl.registerFactory<SetRadioVolume>(() => SetRadioVolume(sl()));
  }

  if (!sl.isRegistered<StopRadioStation>()) {
    sl.registerFactory<StopRadioStation>(() => StopRadioStation(sl()));
  }

  if (!sl.isRegistered<WatchRadioPlayback>()) {
    sl.registerFactory<WatchRadioPlayback>(() => WatchRadioPlayback(sl()));
  }

  if (!sl.isRegistered<DiscoverCubit>()) {
    sl.registerFactory<DiscoverCubit>(
      () => DiscoverCubit(
        getStations: sl(),
        searchStations: sl(),
        getGenres: sl(),
        rankStationsWithAi: sl(),
        startVoiceSearchRecording: sl(),
        stopVoiceSearchRecording: sl(),
        transcribeStationSearch: sl(),
        watchFavoriteStations: sl(),
        toggleFavoriteStation: sl(),
        playRadioStation: sl(),
        pauseRadioStation: sl(),
        resumeRadioStation: sl(),
        setRadioVolume: sl(),
        stopRadioStation: sl(),
        watchRadioPlayback: sl(),
      ),
    );
  }

  if (!sl.isRegistered<FavoritesCubit>()) {
    sl.registerFactory<FavoritesCubit>(
      () => FavoritesCubit(
        watchFavoriteStations: sl(),
        toggleFavoriteStation: sl(),
        searchStations: sl(),
        playRadioStation: sl(),
        pauseRadioStation: sl(),
        resumeRadioStation: sl(),
        setRadioVolume: sl(),
        stopRadioStation: sl(),
        watchRadioPlayback: sl(),
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
