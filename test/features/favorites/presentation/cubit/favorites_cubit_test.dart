import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/toggle_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/watch_favorite_stations.dart';
import 'package:radio_browser/src/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:radio_browser/src/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:radio_browser/src/features/player/domain/entities/radio_playback_snapshot.dart';
import 'package:radio_browser/src/features/player/domain/usecases/pause_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/play_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/resume_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/set_radio_volume.dart';
import 'package:radio_browser/src/features/player/domain/usecases/stop_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/watch_radio_playback.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/station_fixtures.dart';

class MockWatchFavoriteStations extends Mock implements WatchFavoriteStations {}

class MockToggleFavoriteStation extends Mock implements ToggleFavoriteStation {}

class MockPlayRadioStation extends Mock implements PlayRadioStation {}

class MockPauseRadioStation extends Mock implements PauseRadioStation {}

class MockResumeRadioStation extends Mock implements ResumeRadioStation {}

class MockSetRadioVolume extends Mock implements SetRadioVolume {}

class MockStopRadioStation extends Mock implements StopRadioStation {}

class MockWatchRadioPlayback extends Mock implements WatchRadioPlayback {}

void main() {
  late MockWatchFavoriteStations watchFavoriteStations;
  late MockToggleFavoriteStation toggleFavoriteStation;
  late MockPlayRadioStation playRadioStation;
  late MockPauseRadioStation pauseRadioStation;
  late MockResumeRadioStation resumeRadioStation;
  late MockSetRadioVolume setRadioVolume;
  late MockStopRadioStation stopRadioStation;
  late MockWatchRadioPlayback watchRadioPlayback;
  late FavoriteStation favoriteStation;

  FavoritesCubit buildCubit() {
    return FavoritesCubit(
      watchFavoriteStations: watchFavoriteStations,
      toggleFavoriteStation: toggleFavoriteStation,
      playRadioStation: playRadioStation,
      pauseRadioStation: pauseRadioStation,
      resumeRadioStation: resumeRadioStation,
      setRadioVolume: setRadioVolume,
      stopRadioStation: stopRadioStation,
      watchRadioPlayback: watchRadioPlayback,
    );
  }

  setUpAll(() {
    registerFallbackValue(favoriteStationFixture());
    registerFallbackValue(stationFixture());
  });

  setUp(() {
    watchFavoriteStations = MockWatchFavoriteStations();
    toggleFavoriteStation = MockToggleFavoriteStation();
    playRadioStation = MockPlayRadioStation();
    pauseRadioStation = MockPauseRadioStation();
    resumeRadioStation = MockResumeRadioStation();
    setRadioVolume = MockSetRadioVolume();
    stopRadioStation = MockStopRadioStation();
    watchRadioPlayback = MockWatchRadioPlayback();
    favoriteStation = favoriteStationFixture(name: 'Radio Paradise');

    when(() => watchFavoriteStations()).thenAnswer(
      (_) => Stream<Result<List<FavoriteStation>>>.value(
        Success(<FavoriteStation>[favoriteStation]),
      ),
    );
    when(
      () => watchRadioPlayback(),
    ).thenAnswer((_) => const Stream<RadioPlaybackSnapshot>.empty());
    when(
      () => playRadioStation(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => toggleFavoriteStation(any()),
    ).thenAnswer((_) async => const Success<bool>(false));
    when(
      () => pauseRadioStation(),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => resumeRadioStation(),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => setRadioVolume(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => stopRadioStation(),
    ).thenAnswer((_) async => const Success<void>(null));
  });

  blocTest<FavoritesCubit, FavoritesState>(
    'loads favorite stations from the local stream',
    build: buildCubit,
    act: (cubit) async {
      cubit.load();
      await pumpEventQueue();
    },
    verify: (cubit) {
      expect(cubit.state.status, FavoritesStatus.success);
      expect(cubit.state.stations, <FavoriteStation>[favoriteStation]);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'plays a favorite station',
    build: buildCubit,
    act: (cubit) => cubit.playStation(favoriteStation),
    verify: (cubit) {
      final captured = verify(() => playRadioStation(captureAny())).captured;
      expect(captured.single.stationUuid, favoriteStation.stationUuid);
      expect(cubit.state.playbackStatus, RadioPlaybackStatus.loading);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'removes a favorite through the toggle use case',
    build: buildCubit,
    act: (cubit) => cubit.removeFavorite(favoriteStation),
    verify: (_) {
      verify(() => toggleFavoriteStation(favoriteStation)).called(1);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'sets player volume through the use case',
    build: buildCubit,
    act: (cubit) => cubit.setVolume(0.7),
    verify: (_) {
      verify(() => setRadioVolume(0.7)).called(1);
    },
  );

  blocTest<FavoritesCubit, FavoritesState>(
    'stops playback through the use case',
    build: buildCubit,
    act: (cubit) => cubit.stopPlayback(),
    verify: (_) {
      verify(() => stopRadioStation()).called(1);
    },
  );
}
