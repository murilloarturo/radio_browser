import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/app/di/service_locator.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/discover/domain/repositories/station_repository.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_genres.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations_by_uuids.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/resolve_station_stream_url.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/search_stations.dart';
import 'package:radio_browser/src/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:radio_browser/src/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/add_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/get_favorite_stations.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/is_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/remove_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/toggle_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/watch_favorite_stations.dart';
import 'package:radio_browser/src/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:radio_browser/src/features/player/domain/entities/radio_playback_snapshot.dart';
import 'package:radio_browser/src/features/player/domain/repositories/radio_player_repository.dart';
import 'package:radio_browser/src/features/player/domain/usecases/pause_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/play_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/resume_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/set_radio_volume.dart';
import 'package:radio_browser/src/features/player/domain/usecases/stop_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/watch_radio_playback.dart';

import '../../helpers/hive_test_box.dart';

class FakeRadioPlayerRepository implements RadioPlayerRepository {
  @override
  RadioPlaybackSnapshot get currentSnapshot =>
      const RadioPlaybackSnapshot.idle();

  @override
  Future<void> dispose() async {}

  @override
  Future<Result<void>> pause() async => const Success<void>(null);

  @override
  Future<Result<void>> play({
    required Station station,
    required String streamUrl,
  }) async {
    return const Success<void>(null);
  }

  @override
  Future<Result<void>> resume() async => const Success<void>(null);

  @override
  Future<Result<void>> setVolume(double volume) async =>
      const Success<void>(null);

  @override
  Future<Result<void>> stop() async => const Success<void>(null);

  @override
  Stream<RadioPlaybackSnapshot> watchPlayback() {
    return const Stream<RadioPlaybackSnapshot>.empty();
  }
}

void main() {
  late HiveTestBox hive;

  setUp(() async {
    hive = await openHiveTestBox();
  });

  tearDown(() async {
    await getIt.reset();
    await hive.dispose();
  });

  test('registers app dependencies', () async {
    await configureDependencies(
      favoriteStationsBox: hive.favoriteStationsBox,
      radioPlayerRepository: FakeRadioPlayerRepository(),
    );

    expect(getIt<StationRepository>(), isA<StationRepository>());
    expect(getIt<GetStations>(), isA<GetStations>());
    expect(getIt<SearchStations>(), isA<SearchStations>());
    expect(getIt<GetGenres>(), isA<GetGenres>());
    expect(getIt<ResolveStationStreamUrl>(), isA<ResolveStationStreamUrl>());
    expect(getIt<GetStationsByUuids>(), isA<GetStationsByUuids>());
    expect(getIt<DiscoverCubit>(), isA<DiscoverCubit>());

    expect(getIt<FavoritesRepository>(), isA<FavoritesRepository>());
    expect(getIt<GetFavoriteStations>(), isA<GetFavoriteStations>());
    expect(getIt<WatchFavoriteStations>(), isA<WatchFavoriteStations>());
    expect(getIt<AddFavoriteStation>(), isA<AddFavoriteStation>());
    expect(getIt<RemoveFavoriteStation>(), isA<RemoveFavoriteStation>());
    expect(getIt<ToggleFavoriteStation>(), isA<ToggleFavoriteStation>());
    expect(getIt<IsFavoriteStation>(), isA<IsFavoriteStation>());
    expect(getIt<FavoritesCubit>(), isA<FavoritesCubit>());

    expect(getIt<RadioPlayerRepository>(), isA<RadioPlayerRepository>());
    expect(getIt<PlayRadioStation>(), isA<PlayRadioStation>());
    expect(getIt<PauseRadioStation>(), isA<PauseRadioStation>());
    expect(getIt<ResumeRadioStation>(), isA<ResumeRadioStation>());
    expect(getIt<SetRadioVolume>(), isA<SetRadioVolume>());
    expect(getIt<StopRadioStation>(), isA<StopRadioStation>());
    expect(getIt<WatchRadioPlayback>(), isA<WatchRadioPlayback>());
  });
}
