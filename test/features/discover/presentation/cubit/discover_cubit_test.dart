import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_genre.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_search_query.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_genres.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/get_stations.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/search_stations.dart';
import 'package:radio_browser/src/features/discover/presentation/cubit/discover_cubit.dart';
import 'package:radio_browser/src/features/discover/presentation/cubit/discover_filter.dart';
import 'package:radio_browser/src/features/discover/presentation/cubit/discover_state.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/toggle_favorite_station.dart';
import 'package:radio_browser/src/features/favorites/domain/usecases/watch_favorite_stations.dart';
import 'package:radio_browser/src/features/player/domain/entities/radio_playback_snapshot.dart';
import 'package:radio_browser/src/features/player/domain/usecases/pause_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/play_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/resume_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/watch_radio_playback.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/station_fixtures.dart';

class MockGetStations extends Mock implements GetStations {}

class MockSearchStations extends Mock implements SearchStations {}

class MockGetGenres extends Mock implements GetGenres {}

class MockWatchFavoriteStations extends Mock implements WatchFavoriteStations {}

class MockToggleFavoriteStation extends Mock implements ToggleFavoriteStation {}

class MockPlayRadioStation extends Mock implements PlayRadioStation {}

class MockPauseRadioStation extends Mock implements PauseRadioStation {}

class MockResumeRadioStation extends Mock implements ResumeRadioStation {}

class MockWatchRadioPlayback extends Mock implements WatchRadioPlayback {}

void main() {
  late MockGetStations getStations;
  late MockSearchStations searchStations;
  late MockGetGenres getGenres;
  late MockWatchFavoriteStations watchFavoriteStations;
  late MockToggleFavoriteStation toggleFavoriteStation;
  late MockPlayRadioStation playRadioStation;
  late MockPauseRadioStation pauseRadioStation;
  late MockResumeRadioStation resumeRadioStation;
  late MockWatchRadioPlayback watchRadioPlayback;
  late Station station;
  late FavoriteStation favoriteStation;

  DiscoverCubit buildCubit() {
    return DiscoverCubit(
      getStations: getStations,
      searchStations: searchStations,
      getGenres: getGenres,
      watchFavoriteStations: watchFavoriteStations,
      toggleFavoriteStation: toggleFavoriteStation,
      playRadioStation: playRadioStation,
      pauseRadioStation: pauseRadioStation,
      resumeRadioStation: resumeRadioStation,
      watchRadioPlayback: watchRadioPlayback,
    );
  }

  setUpAll(() {
    registerFallbackValue(const StationSearchQuery());
    registerFallbackValue(favoriteStationFixture());
    registerFallbackValue(stationFixture());
  });

  setUp(() {
    getStations = MockGetStations();
    searchStations = MockSearchStations();
    getGenres = MockGetGenres();
    watchFavoriteStations = MockWatchFavoriteStations();
    toggleFavoriteStation = MockToggleFavoriteStation();
    playRadioStation = MockPlayRadioStation();
    pauseRadioStation = MockPauseRadioStation();
    resumeRadioStation = MockResumeRadioStation();
    watchRadioPlayback = MockWatchRadioPlayback();
    station = stationFixture();
    favoriteStation = favoriteStationFixture(
      stationUuid: station.stationUuid,
      name: station.name,
    );

    when(() => watchFavoriteStations()).thenAnswer(
      (_) => Stream<Result<List<FavoriteStation>>>.value(
        Success(<FavoriteStation>[favoriteStation]),
      ),
    );
    when(() => getGenres()).thenAnswer(
      (_) async => const Success<List<StationGenre>>([
        StationGenre(name: 'jazz', stationCount: 20),
      ]),
    );
    when(
      () => getStations(query: any(named: 'query')),
    ).thenAnswer((_) async => Success<List<Station>>([station]));
    when(
      () => searchStations(any()),
    ).thenAnswer((_) async => Success<List<Station>>([station]));
    when(
      () => toggleFavoriteStation(any()),
    ).thenAnswer((_) async => const Success<bool>(true));
    when(
      () => playRadioStation(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => pauseRadioStation(),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => resumeRadioStation(),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => watchRadioPlayback(),
    ).thenAnswer((_) => const Stream<RadioPlaybackSnapshot>.empty());
  });

  blocTest<DiscoverCubit, DiscoverState>(
    'loads genres, stations, and favorites',
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await pumpEventQueue();
    },
    verify: (cubit) {
      expect(cubit.state.status, DiscoverStatus.success);
      expect(cubit.state.stations, <Station>[station]);
      expect(cubit.state.genres, const <StationGenre>[
        StationGenre(name: 'jazz', stationCount: 20),
      ]);
      expect(cubit.isFavorite(station.stationUuid), isTrue);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'searches stations with the submitted term',
    build: buildCubit,
    act: (cubit) => cubit.search('bbc'),
    verify: (_) {
      final captured = verify(() => searchStations(captureAny())).captured;
      expect(captured.single, isA<StationSearchQuery>());
      expect((captured.single as StationSearchQuery).name, 'bbc');
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'loads default stations when search term is cleared',
    build: buildCubit,
    seed: () => const DiscoverState(searchTerm: 'bbc'),
    act: (cubit) => cubit.search('  '),
    verify: (_) {
      verifyNever(() => searchStations(any()));
      final captured =
          verify(() => getStations(query: captureAny(named: 'query'))).captured;
      expect((captured.single as StationSearchQuery).name, isNull);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'loads selected filter query',
    build: buildCubit,
    act: (cubit) => cubit.selectFilter(DiscoverFilter.jazz),
    verify: (cubit) {
      final captured =
          verify(() => getStations(query: captureAny(named: 'query'))).captured;
      expect((captured.single as StationSearchQuery).tag, 'jazz');
      expect(cubit.state.activeFilter, DiscoverFilter.jazz);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'starts playback and sets mini-player loading state',
    build: buildCubit,
    act: (cubit) => cubit.playStation(station),
    verify: (cubit) {
      verify(() => playRadioStation(station)).called(1);
      expect(cubit.state.activeStation, station);
      expect(cubit.state.playbackStatus, RadioPlaybackStatus.loading);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'updates playback state from the player stream',
    setUp: () {
      when(() => watchRadioPlayback()).thenAnswer(
        (_) => Stream<RadioPlaybackSnapshot>.value(
          RadioPlaybackSnapshot(
            status: RadioPlaybackStatus.playing,
            station: station,
          ),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await pumpEventQueue();
    },
    verify: (cubit) {
      expect(cubit.state.activeStation, station);
      expect(cubit.state.isMiniPlayerPlaying, isTrue);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'pauses active playback from mini-player',
    build: buildCubit,
    seed:
        () => DiscoverState(
          activeStation: station,
          playbackStatus: RadioPlaybackStatus.playing,
        ),
    act: (cubit) => cubit.toggleMiniPlayerPlayback(),
    verify: (_) {
      verify(() => pauseRadioStation()).called(1);
      verifyNever(() => resumeRadioStation());
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'resumes paused playback from mini-player',
    build: buildCubit,
    seed:
        () => DiscoverState(
          activeStation: station,
          playbackStatus: RadioPlaybackStatus.paused,
        ),
    act: (cubit) => cubit.toggleMiniPlayerPlayback(),
    verify: (_) {
      verify(() => resumeRadioStation()).called(1);
      verifyNever(() => pauseRadioStation());
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'toggles favorite through the use case',
    build: buildCubit,
    act: (cubit) => cubit.toggleFavorite(station),
    verify: (_) {
      final captured =
          verify(() => toggleFavoriteStation(captureAny())).captured;
      expect(
        (captured.single as FavoriteStation).stationUuid,
        station.stationUuid,
      );
    },
  );
}
