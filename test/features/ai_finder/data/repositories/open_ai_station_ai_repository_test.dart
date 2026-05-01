import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/config/open_ai_config.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/ai_finder/data/datasources/open_ai_remote_data_source.dart';
import 'package:radio_browser/src/features/ai_finder/data/repositories/open_ai_station_ai_repository.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/station_fixtures.dart';

class MockOpenAiRemoteDataSource extends Mock
    implements OpenAiRemoteDataSource {}

void main() {
  late MockOpenAiRemoteDataSource remoteDataSource;
  late Station station;
  late FavoriteStation favoriteStation;

  setUpAll(() {
    registerFallbackValue(<Station>[]);
    registerFallbackValue(<FavoriteStation>[]);
  });

  setUp(() {
    remoteDataSource = MockOpenAiRemoteDataSource();
    station = stationFixture();
    favoriteStation = favoriteStationFixture();
  });

  test('returns unavailable failure when API key is missing', () async {
    final repository = OpenAiStationAiRepository(
      config: const OpenAiConfig(
        apiKey: '',
        model: 'gpt-5-mini',
        transcriptionModel: 'gpt-4o-mini-transcribe',
      ),
      remoteDataSource: remoteDataSource,
    );

    final result = await repository.rankStationUuids(
      prompt: 'focus',
      candidateStations: [station],
      favoriteStations: [favoriteStation],
    );

    expect(result, isA<Failure<List<String>>>());
    expect(
      (result as Failure<List<String>>).failure,
      isA<AiUnavailableFailure>(),
    );
  });

  test('returns remote station UUIDs when OpenAI is enabled', () async {
    final repository = OpenAiStationAiRepository(
      config: const OpenAiConfig(
        apiKey: 'test-key',
        model: 'gpt-5-mini',
        transcriptionModel: 'gpt-4o-mini-transcribe',
      ),
      remoteDataSource: remoteDataSource,
    );

    when(
      () => remoteDataSource.rankStationUuids(
        prompt: 'focus',
        candidateStations: any(named: 'candidateStations'),
        favoriteStations: any(named: 'favoriteStations'),
      ),
    ).thenAnswer((_) async => const <String>['station-1']);

    final result = await repository.rankStationUuids(
      prompt: 'focus',
      candidateStations: [station],
      favoriteStations: [favoriteStation],
    );

    expect(result.when(success: (uuids) => uuids, failure: (_) => <String>[]), [
      'station-1',
    ]);
  });
}
