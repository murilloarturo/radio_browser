import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/ai_finder/domain/usecases/rank_stations_with_ai.dart';
import 'package:radio_browser/src/features/ai_finder/domain/usecases/start_voice_search_recording.dart';
import 'package:radio_browser/src/features/ai_finder/domain/usecases/stop_voice_search_recording.dart';
import 'package:radio_browser/src/features/ai_finder/domain/usecases/transcribe_station_search.dart';
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
import 'package:radio_browser/src/features/player/domain/usecases/set_radio_volume.dart';
import 'package:radio_browser/src/features/player/domain/usecases/stop_radio_station.dart';
import 'package:radio_browser/src/features/player/domain/usecases/watch_radio_playback.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/station_fixtures.dart';

class MockGetStations extends Mock implements GetStations {}

class MockSearchStations extends Mock implements SearchStations {}

class MockGetGenres extends Mock implements GetGenres {}

class MockRankStationsWithAi extends Mock implements RankStationsWithAi {}

class MockStartVoiceSearchRecording extends Mock
    implements StartVoiceSearchRecording {}

class MockStopVoiceSearchRecording extends Mock
    implements StopVoiceSearchRecording {}

class MockTranscribeStationSearch extends Mock
    implements TranscribeStationSearch {}

class MockWatchFavoriteStations extends Mock implements WatchFavoriteStations {}

class MockToggleFavoriteStation extends Mock implements ToggleFavoriteStation {}

class MockPlayRadioStation extends Mock implements PlayRadioStation {}

class MockPauseRadioStation extends Mock implements PauseRadioStation {}

class MockResumeRadioStation extends Mock implements ResumeRadioStation {}

class MockSetRadioVolume extends Mock implements SetRadioVolume {}

class MockStopRadioStation extends Mock implements StopRadioStation {}

class MockWatchRadioPlayback extends Mock implements WatchRadioPlayback {}

void main() {
  late MockGetStations getStations;
  late MockSearchStations searchStations;
  late MockGetGenres getGenres;
  late MockRankStationsWithAi rankStationsWithAi;
  late MockStartVoiceSearchRecording startVoiceSearchRecording;
  late MockStopVoiceSearchRecording stopVoiceSearchRecording;
  late MockTranscribeStationSearch transcribeStationSearch;
  late MockWatchFavoriteStations watchFavoriteStations;
  late MockToggleFavoriteStation toggleFavoriteStation;
  late MockPlayRadioStation playRadioStation;
  late MockPauseRadioStation pauseRadioStation;
  late MockResumeRadioStation resumeRadioStation;
  late MockSetRadioVolume setRadioVolume;
  late MockStopRadioStation stopRadioStation;
  late MockWatchRadioPlayback watchRadioPlayback;
  late Station station;
  late FavoriteStation favoriteStation;
  late StreamController<Result<List<FavoriteStation>>> favoritesController;

  DiscoverCubit buildCubit() {
    return DiscoverCubit(
      getStations: getStations,
      searchStations: searchStations,
      getGenres: getGenres,
      rankStationsWithAi: rankStationsWithAi,
      startVoiceSearchRecording: startVoiceSearchRecording,
      stopVoiceSearchRecording: stopVoiceSearchRecording,
      transcribeStationSearch: transcribeStationSearch,
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
    registerFallbackValue(const StationSearchQuery());
    registerFallbackValue(<Station>[]);
    registerFallbackValue(<FavoriteStation>[]);
    registerFallbackValue(favoriteStationFixture());
    registerFallbackValue(stationFixture());
  });

  setUp(() {
    getStations = MockGetStations();
    searchStations = MockSearchStations();
    getGenres = MockGetGenres();
    rankStationsWithAi = MockRankStationsWithAi();
    startVoiceSearchRecording = MockStartVoiceSearchRecording();
    stopVoiceSearchRecording = MockStopVoiceSearchRecording();
    transcribeStationSearch = MockTranscribeStationSearch();
    watchFavoriteStations = MockWatchFavoriteStations();
    toggleFavoriteStation = MockToggleFavoriteStation();
    playRadioStation = MockPlayRadioStation();
    pauseRadioStation = MockPauseRadioStation();
    resumeRadioStation = MockResumeRadioStation();
    setRadioVolume = MockSetRadioVolume();
    stopRadioStation = MockStopRadioStation();
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
    when(() => rankStationsWithAi.isEnabled).thenReturn(false);
    when(
      () => rankStationsWithAi(
        prompt: any(named: 'prompt'),
        candidateStations: any(named: 'candidateStations'),
        favoriteStations: any(named: 'favoriteStations'),
      ),
    ).thenAnswer((invocation) async {
      return Success<List<Station>>(
        invocation.namedArguments[#candidateStations] as List<Station>,
      );
    });
    when(() => transcribeStationSearch.isEnabled).thenReturn(false);
    when(
      () => startVoiceSearchRecording(),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => stopVoiceSearchRecording(),
    ).thenAnswer((_) async => const Success<String?>('/tmp/search.m4a'));
    when(
      () => transcribeStationSearch(any()),
    ).thenAnswer((_) async => const Success<String>('jazz'));
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
      () => setRadioVolume(any()),
    ).thenAnswer((_) async => const Success<void>(null));
    when(
      () => stopRadioStation(),
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
    'marks network failures for the offline state',
    setUp: () {
      when(
        () => getStations(query: any(named: 'query')),
      ).thenAnswer((_) async => const Failure<List<Station>>(NetworkFailure()));
    },
    build: buildCubit,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, DiscoverStatus.failure);
      expect(cubit.state.failureKind, DiscoverFailureKind.network);
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
    'uses OpenAI to rank real Radio Browser candidates for search',
    setUp: () {
      final secondStation = stationFixture(
        stationUuid: 'station-2',
        name: 'Focus Radio',
        tags: const <String>['focus'],
      );
      when(() => rankStationsWithAi.isEnabled).thenReturn(true);
      when(
        () => searchStations(any()),
      ).thenAnswer((_) async => Success<List<Station>>([station]));
      when(
        () => getStations(query: any(named: 'query')),
      ).thenAnswer((_) async => Success<List<Station>>([secondStation]));
      when(
        () => rankStationsWithAi(
          prompt: 'focus music',
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).thenAnswer(
        (_) async => Success<List<Station>>([secondStation, station]),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.search('focus music');
      await pumpEventQueue();
    },
    verify: (cubit) {
      expect(cubit.state.stations.map((station) => station.stationUuid), [
        'station-2',
        station.stationUuid,
      ]);
      expect(
        cubit.state.aiRecommendationStatus,
        AiRecommendationStatus.initial,
      );
      expect(cubit.state.recommendedStations, isEmpty);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'shows stations before background OpenAI ranking completes',
    setUp: () {
      final rankingCompleter = Completer<Result<List<Station>>>();
      addTearDown(() {
        if (!rankingCompleter.isCompleted) {
          rankingCompleter.complete(Success<List<Station>>([station]));
        }
      });
      when(() => rankStationsWithAi.isEnabled).thenReturn(true);
      when(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).thenAnswer((_) => rankingCompleter.future);
    },
    build: buildCubit,
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect(cubit.state.status, DiscoverStatus.success);
      expect(cubit.state.stations, [station]);
      expect(cubit.state.recommendedStations, isEmpty);
      expect(
        cubit.state.aiRecommendationStatus,
        AiRecommendationStatus.loading,
      );
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'keeps stations visible when background OpenAI ranking fails',
    setUp: () {
      when(() => rankStationsWithAi.isEnabled).thenReturn(true);
      when(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).thenAnswer(
        (_) async => const Failure<List<Station>>(
          DecodingFailure('Unable to read the OpenAI response.'),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await pumpEventQueue();
    },
    verify: (cubit) {
      expect(cubit.state.status, DiscoverStatus.success);
      expect(cubit.state.stations, [station]);
      expect(cubit.state.recommendedStations, isEmpty);
      expect(
        cubit.state.aiRecommendationStatus,
        AiRecommendationStatus.unavailable,
      );
      expect(
        cubit.state.aiFailureMessage,
        'Unable to read the OpenAI response.',
      );
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'waits for stored favorites before calculating initial recommendations',
    setUp: () {
      final taggedStation = stationFixture(
        stationUuid: 'tagged-jazz',
        name: 'Tagged Jazz',
        tags: const <String>['jazz'],
      );
      favoritesController = StreamController<Result<List<FavoriteStation>>>();
      addTearDown(favoritesController.close);
      when(
        () => watchFavoriteStations(),
      ).thenAnswer((_) => favoritesController.stream);
      when(() => rankStationsWithAi.isEnabled).thenReturn(true);
      when(() => searchStations(any())).thenAnswer((invocation) async {
        final query =
            invocation.positionalArguments.single as StationSearchQuery;
        if (query.tag == 'jazz') {
          return Success<List<Station>>([taggedStation]);
        }

        return Success<List<Station>>([station]);
      });
      when(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).thenAnswer((_) async => Success<List<Station>>([taggedStation]));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await pumpEventQueue();

      verifyNever(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      );

      favoritesController.add(
        Success<List<FavoriteStation>>([
          favoriteStationFixture(
            stationUuid: 'favorite-only',
            name: 'Favorite Jazz',
          ),
        ]),
      );
      await pumpEventQueue();
    },
    verify: (cubit) {
      final captured =
          verify(
            () => rankStationsWithAi(
              prompt: captureAny(named: 'prompt'),
              candidateStations: captureAny(named: 'candidateStations'),
              favoriteStations: captureAny(named: 'favoriteStations'),
            ),
          ).captured;
      final prompt = captured[0] as String;
      final candidateStations = captured[1] as List<Station>;
      final favoriteStations = captured[2] as List<FavoriteStation>;

      expect(prompt, contains('similar to my favorites'));
      expect(
        candidateStations.map((station) => station.stationUuid),
        containsAll(<String>['favorite-only', 'tagged-jazz']),
      );
      expect(favoriteStations.map((station) => station.stationUuid), [
        'favorite-only',
      ]);
      expect(cubit.state.recommendedStations.first.stationUuid, 'tagged-jazz');
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'calculates recommendations only on the first successful app load',
    setUp: () {
      favoritesController = StreamController<Result<List<FavoriteStation>>>();
      addTearDown(favoritesController.close);
      when(
        () => watchFavoriteStations(),
      ).thenAnswer((_) => favoritesController.stream);
      when(() => rankStationsWithAi.isEnabled).thenReturn(true);
      when(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).thenAnswer((_) async => Success<List<Station>>([station]));
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.load();
      await pumpEventQueue();

      favoritesController.add(
        Success<List<FavoriteStation>>([favoriteStation]),
      );
      await pumpEventQueue();

      await cubit.selectFilter(DiscoverFilter.jazz);
      await pumpEventQueue();
    },
    verify: (cubit) {
      verify(
        () => rankStationsWithAi(
          prompt: any(named: 'prompt'),
          candidateStations: any(named: 'candidateStations'),
          favoriteStations: any(named: 'favoriteStations'),
        ),
      ).called(1);
      expect(cubit.state.aiRecommendationStatus, AiRecommendationStatus.ready);
      expect(cubit.state.recommendedStations, [station]);
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

  blocTest<DiscoverCubit, DiscoverState>(
    'sets player volume through the use case',
    build: buildCubit,
    act: (cubit) => cubit.setVolume(0.4),
    verify: (_) {
      verify(() => setRadioVolume(0.4)).called(1);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'stops playback through the use case',
    build: buildCubit,
    act: (cubit) => cubit.stopPlayback(),
    verify: (_) {
      verify(() => stopRadioStation()).called(1);
    },
  );

  blocTest<DiscoverCubit, DiscoverState>(
    'records, transcribes, and searches a voice query',
    setUp: () {
      when(() => transcribeStationSearch.isEnabled).thenReturn(true);
    },
    build: buildCubit,
    act: (cubit) async {
      await cubit.toggleVoiceSearch();
      await cubit.toggleVoiceSearch();
    },
    verify: (_) {
      verify(() => startVoiceSearchRecording()).called(1);
      verify(() => stopVoiceSearchRecording()).called(1);
      verify(() => transcribeStationSearch('/tmp/search.m4a')).called(1);
      final captured = verify(() => searchStations(captureAny())).captured;
      expect((captured.single as StationSearchQuery).name, 'jazz');
    },
  );
}
