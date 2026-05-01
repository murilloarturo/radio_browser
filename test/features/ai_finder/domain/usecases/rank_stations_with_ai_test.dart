import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/ai_finder/domain/repositories/station_ai_repository.dart';
import 'package:radio_browser/src/features/ai_finder/domain/usecases/rank_stations_with_ai.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/station_fixtures.dart';

class MockStationAiRepository extends Mock implements StationAiRepository {}

void main() {
  late MockStationAiRepository repository;
  late RankStationsWithAi useCase;
  late Station stationOne;
  late Station stationTwo;
  late FavoriteStation favoriteStation;

  setUpAll(() {
    registerFallbackValue(<Station>[]);
    registerFallbackValue(<FavoriteStation>[]);
  });

  setUp(() {
    repository = MockStationAiRepository();
    useCase = RankStationsWithAi(repository);
    stationOne = stationFixture(stationUuid: 'station-1');
    stationTwo = stationFixture(stationUuid: 'station-2');
    favoriteStation = favoriteStationFixture(stationUuid: 'favorite-1');
  });

  test('returns candidates unchanged when OpenAI is disabled', () async {
    when(() => repository.isEnabled).thenReturn(false);

    final result = await useCase(
      prompt: 'focus',
      candidateStations: [stationOne, stationTwo],
      favoriteStations: [favoriteStation],
    );

    expect(
      result.when(success: (stations) => stations, failure: (_) => <Station>[]),
      [stationOne, stationTwo],
    );
    verifyNever(
      () => repository.rankStationUuids(
        prompt: any(named: 'prompt'),
        candidateStations: any(named: 'candidateStations'),
        favoriteStations: any(named: 'favoriteStations'),
      ),
    );
  });

  test('orders candidates by returned station UUIDs', () async {
    when(() => repository.isEnabled).thenReturn(true);
    when(
      () => repository.rankStationUuids(
        prompt: 'focus',
        candidateStations: any(named: 'candidateStations'),
        favoriteStations: any(named: 'favoriteStations'),
      ),
    ).thenAnswer((_) async => const Success<List<String>>(['station-2']));

    final result = await useCase(
      prompt: 'focus',
      candidateStations: [stationOne, stationTwo],
      favoriteStations: [favoriteStation],
    );

    expect(
      result.when(success: (stations) => stations, failure: (_) => <Station>[]),
      [stationTwo, stationOne],
    );
  });

  test('returns failure when OpenAI ranking fails', () async {
    when(() => repository.isEnabled).thenReturn(true);
    when(
      () => repository.rankStationUuids(
        prompt: 'focus',
        candidateStations: any(named: 'candidateStations'),
        favoriteStations: any(named: 'favoriteStations'),
      ),
    ).thenAnswer((_) async => const Failure<List<String>>(UnknownFailure()));

    final result = await useCase(
      prompt: 'focus',
      candidateStations: [stationOne, stationTwo],
    );

    expect(result, isA<Failure<List<Station>>>());
  });
}
