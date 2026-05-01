import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/network/radio_browser_api_exception.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/discover/data/datasources/radio_browser_remote_data_source.dart';
import 'package:radio_browser/src/features/discover/data/models/resolved_station_stream_dto.dart';
import 'package:radio_browser/src/features/discover/data/models/station_dto.dart';
import 'package:radio_browser/src/features/discover/data/models/station_genre_dto.dart';
import 'package:radio_browser/src/features/discover/data/repositories/radio_browser_station_repository.dart';
import 'package:radio_browser/src/features/discover/domain/entities/resolved_station_stream.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_genre.dart';
import 'package:radio_browser/src/features/discover/domain/entities/station_search_query.dart';

class MockRadioBrowserRemoteDataSource extends Mock
    implements RadioBrowserRemoteDataSource {}

void main() {
  late MockRadioBrowserRemoteDataSource remoteDataSource;
  late RadioBrowserStationRepository repository;

  const stationDto = StationDto(
    stationUuid: 'station-1',
    name: 'Demo Radio',
    streamUrl: 'https://example.com/stream',
    tags: <String>['jazz'],
    lastCheckOk: true,
  );

  setUpAll(() {
    registerFallbackValue(const StationSearchQuery());
  });

  setUp(() {
    remoteDataSource = MockRadioBrowserRemoteDataSource();
    repository = RadioBrowserStationRepository(
      remoteDataSource: remoteDataSource,
    );
  });

  test('returns stations on success', () async {
    when(
      () => remoteDataSource.getStations(any()),
    ).thenAnswer((_) async => const <StationDto>[stationDto]);

    final result = await repository.getStations();

    expect(result, isA<Success<List<Station>>>());
    expect((result as Success<List<Station>>).value, <Station>[
      stationDto.toDomain(),
    ]);
  });

  test('returns genres on success', () async {
    when(() => remoteDataSource.getGenres()).thenAnswer(
      (_) async => const <StationGenreDto>[
        StationGenreDto(name: 'jazz', stationCount: 20),
      ],
    );

    final result = await repository.getGenres();

    expect(result, isA<Success<List<StationGenre>>>());
    expect((result as Success<List<StationGenre>>).value, const <StationGenre>[
      StationGenre(name: 'jazz', stationCount: 20),
    ]);
  });

  test('returns stations by UUID on success', () async {
    when(
      () => remoteDataSource.getStationsByUuids(const <String>['station-1']),
    ).thenAnswer((_) async => const <StationDto>[stationDto]);

    final result = await repository.getStationsByUuids(const <String>[
      'station-1',
    ]);

    expect(result, isA<Success<List<Station>>>());
    expect(
      (result as Success<List<Station>>).value.single.stationUuid,
      'station-1',
    );
  });

  test('returns resolved stream on success', () async {
    when(
      () => remoteDataSource.resolveStationStreamUrl('station-1'),
    ).thenAnswer(
      (_) async => const ResolvedStationStreamDto(
        ok: true,
        message: 'retrieved station url',
        stationUuid: 'station-1',
        name: 'Demo Radio',
        url: 'https://example.com/live.mp3',
      ),
    );

    final result = await repository.resolveStationStreamUrl('station-1');

    expect(result, isA<Success<ResolvedStationStream>>());
    expect(
      (result as Success<ResolvedStationStream>).value.url,
      'https://example.com/live.mp3',
    );
  });

  test(
    'maps unavailable stream response to unavailable station failure',
    () async {
      when(
        () => remoteDataSource.resolveStationStreamUrl('station-1'),
      ).thenAnswer(
        (_) async => const ResolvedStationStreamDto(
          ok: false,
          message: 'station not found',
          stationUuid: 'station-1',
          name: 'Demo Radio',
          url: '',
        ),
      );

      final result = await repository.resolveStationStreamUrl('station-1');

      expect(result, isA<Failure<ResolvedStationStream>>());
      expect(
        (result as Failure<ResolvedStationStream>).failure,
        isA<UnavailableStationFailure>(),
      );
    },
  );

  test('maps connection errors to network failure', () async {
    when(() => remoteDataSource.getStations(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/json/stations/search'),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await repository.getStations();

    expect(result, isA<Failure<List<Station>>>());
    expect((result as Failure<List<Station>>).failure, isA<NetworkFailure>());
  });

  test('maps server responses to server failure', () async {
    when(() => remoteDataSource.getStations(any())).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/json/stations/search'),
        response: Response<Object?>(
          requestOptions: RequestOptions(path: '/json/stations/search'),
          statusCode: 503,
        ),
        type: DioExceptionType.badResponse,
      ),
    );

    final result = await repository.getStations();

    expect(result, isA<Failure<List<Station>>>());
    final failure = (result as Failure<List<Station>>).failure;
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 503);
  });

  test('maps decoding errors to decoding failure', () async {
    when(
      () => remoteDataSource.getStations(any()),
    ).thenThrow(const RadioBrowserDecodingException('invalid payload'));

    final result = await repository.getStations();

    expect(result, isA<Failure<List<Station>>>());
    expect((result as Failure<List<Station>>).failure, isA<DecodingFailure>());
  });
}
