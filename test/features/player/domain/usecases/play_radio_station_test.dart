import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/discover/domain/entities/resolved_station_stream.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/discover/domain/usecases/resolve_station_stream_url.dart';
import 'package:radio_browser/src/features/player/domain/repositories/radio_player_repository.dart';
import 'package:radio_browser/src/features/player/domain/usecases/play_radio_station.dart';

import '../../../../helpers/station_fixtures.dart';

class MockResolveStationStreamUrl extends Mock
    implements ResolveStationStreamUrl {}

class MockRadioPlayerRepository extends Mock implements RadioPlayerRepository {}

void main() {
  late MockResolveStationStreamUrl resolveStationStreamUrl;
  late MockRadioPlayerRepository radioPlayerRepository;
  late PlayRadioStation useCase;
  late Station station;

  setUpAll(() {
    registerFallbackValue(stationFixture());
  });

  setUp(() {
    resolveStationStreamUrl = MockResolveStationStreamUrl();
    radioPlayerRepository = MockRadioPlayerRepository();
    useCase = PlayRadioStation(
      resolveStationStreamUrl: resolveStationStreamUrl,
      radioPlayerRepository: radioPlayerRepository,
    );
    station = stationFixture();
  });

  test('resolves the click URL before playing the station', () async {
    const resolvedStream = ResolvedStationStream(
      stationUuid: 'station-1',
      name: 'Radio Paradise',
      url: 'https://stream.example.com/radio.mp3',
    );
    when(
      () => resolveStationStreamUrl(station.stationUuid),
    ).thenAnswer((_) async => const Success(resolvedStream));
    when(
      () => radioPlayerRepository.play(
        station: any(named: 'station'),
        streamUrl: any(named: 'streamUrl'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));

    final result = await useCase(station);

    expect(result.isSuccess, isTrue);
    verify(() => resolveStationStreamUrl(station.stationUuid)).called(1);
    verify(
      () => radioPlayerRepository.play(
        station: station,
        streamUrl: resolvedStream.url,
      ),
    ).called(1);
  });

  test('does not start player when stream resolution fails', () async {
    when(() => resolveStationStreamUrl(station.stationUuid)).thenAnswer(
      (_) async =>
          const Failure<ResolvedStationStream>(UnavailableStationFailure()),
    );

    final result = await useCase(station);

    expect(result.isFailure, isTrue);
    verifyNever(
      () => radioPlayerRepository.play(
        station: any(named: 'station'),
        streamUrl: any(named: 'streamUrl'),
      ),
    );
  });
}
