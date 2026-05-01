import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_browser/src/core/error/app_failure.dart';
import 'package:radio_browser/src/core/result/result.dart';
import 'package:radio_browser/src/features/favorites/data/datasources/favorite_stations_local_data_source.dart';
import 'package:radio_browser/src/features/favorites/data/repositories/hive_favorites_repository.dart';
import 'package:radio_browser/src/features/favorites/domain/entities/favorite_station.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/hive_test_box.dart';

class MockFavoriteStationsLocalDataSource extends Mock
    implements FavoriteStationsLocalDataSource {}

void main() {
  group('with Hive data source', () {
    late HiveTestBox hive;
    late HiveFavoritesRepository repository;

    setUp(() async {
      hive = await openHiveTestBox();
      repository = HiveFavoritesRepository(
        localDataSource: HiveFavoriteStationsLocalDataSource(
          box: hive.favoriteStationsBox,
        ),
      );
    });

    tearDown(() async {
      await hive.dispose();
    });

    test('adds and returns favorite stations', () async {
      final station = favoriteStationFixture();

      final addResult = await repository.addFavoriteStation(station);
      final getResult = await repository.getFavoriteStations();

      expect(addResult, isA<Success<void>>());
      expect(getResult, isA<Success<List<FavoriteStation>>>());
      expect(
        (getResult as Success<List<FavoriteStation>>).value,
        <FavoriteStation>[station],
      );
    });

    test('adding the same station twice is idempotent', () async {
      final original = favoriteStationFixture(createdAt: DateTime.utc(2026, 5));
      final duplicate = favoriteStationFixture(
        createdAt: DateTime.utc(2026, 5, 2),
      );

      await repository.addFavoriteStation(original);
      await repository.addFavoriteStation(duplicate);

      final result = await repository.getFavoriteStations();

      expect(result, isA<Success<List<FavoriteStation>>>());
      final favorites = (result as Success<List<FavoriteStation>>).value;
      expect(favorites, hasLength(1));
      expect(favorites.single.createdAt, original.createdAt);
    });

    test('removes a favorite station', () async {
      final station = favoriteStationFixture();

      await repository.addFavoriteStation(station);
      final removeResult = await repository.removeFavoriteStation(
        station.stationUuid,
      );
      final isFavoriteResult = await repository.isFavoriteStation(
        station.stationUuid,
      );

      expect(removeResult, isA<Success<void>>());
      expect((isFavoriteResult as Success<bool>).value, isFalse);
    });

    test('removing a missing favorite is successful', () async {
      final result = await repository.removeFavoriteStation('missing');

      expect(result, isA<Success<void>>());
    });

    test('toggles favorite station on and off', () async {
      final station = favoriteStationFixture();

      final firstToggle = await repository.toggleFavoriteStation(station);
      final secondToggle = await repository.toggleFavoriteStation(station);

      expect((firstToggle as Success<bool>).value, isTrue);
      expect((secondToggle as Success<bool>).value, isFalse);
    });

    test('watches favorite station changes', () async {
      final station = favoriteStationFixture();
      final iterator = StreamIterator(repository.watchFavoriteStations());

      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current, isA<Success<List<FavoriteStation>>>());

      await repository.addFavoriteStation(station);

      expect(await iterator.moveNext(), isTrue);
      final result = iterator.current as Success<List<FavoriteStation>>;
      expect(result.value.single, station);

      await iterator.cancel();
    });
  });

  group('failure mapping', () {
    late MockFavoriteStationsLocalDataSource dataSource;
    late HiveFavoritesRepository repository;

    setUp(() {
      dataSource = MockFavoriteStationsLocalDataSource();
      repository = HiveFavoritesRepository(localDataSource: dataSource);
    });

    test('maps local storage failures', () async {
      when(
        () => dataSource.getFavoriteStations(),
      ).thenThrow(StateError('box closed'));

      final result = await repository.getFavoriteStations();

      expect(result, isA<Failure<List<FavoriteStation>>>());
      expect(
        (result as Failure<List<FavoriteStation>>).failure,
        isA<PersistenceFailure>(),
      );
    });
  });
}
