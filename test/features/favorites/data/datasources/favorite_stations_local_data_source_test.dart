import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/favorites/data/datasources/favorite_stations_local_data_source.dart';
import 'package:radio_browser/src/features/favorites/data/models/favorite_station_hive_model.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/hive_test_box.dart';

void main() {
  late HiveTestBox hive;
  late HiveFavoriteStationsLocalDataSource dataSource;

  setUp(() async {
    hive = await openHiveTestBox();
    dataSource = HiveFavoriteStationsLocalDataSource(
      box: hive.favoriteStationsBox,
    );
  });

  tearDown(() async {
    await hive.dispose();
  });

  test('saves and returns favorites newest first', () async {
    final older = FavoriteStationHiveModel.fromDomain(
      favoriteStationFixture(
        stationUuid: 'older',
        createdAt: DateTime.utc(2026, 5),
      ),
    );
    final newer = FavoriteStationHiveModel.fromDomain(
      favoriteStationFixture(
        stationUuid: 'newer',
        createdAt: DateTime.utc(2026, 5, 2),
      ),
    );

    await dataSource.saveFavoriteStation(older);
    await dataSource.saveFavoriteStation(newer);

    final favorites = await dataSource.getFavoriteStations();

    expect(favorites.map((favorite) => favorite.stationUuid), <String>[
      'newer',
      'older',
    ]);
  });

  test('removes favorites and checks existence', () async {
    final favorite = FavoriteStationHiveModel.fromDomain(
      favoriteStationFixture(),
    );

    await dataSource.saveFavoriteStation(favorite);
    expect(await dataSource.containsFavoriteStation('station-1'), isTrue);

    await dataSource.removeFavoriteStation('station-1');

    expect(await dataSource.containsFavoriteStation('station-1'), isFalse);
    expect(await dataSource.getFavoriteStations(), isEmpty);
  });

  test('emits current favorites and updates', () async {
    final favorite = FavoriteStationHiveModel.fromDomain(
      favoriteStationFixture(),
    );
    final iterator = StreamIterator(dataSource.watchFavoriteStations());

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isEmpty);

    await dataSource.saveFavoriteStation(favorite);

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.single.stationUuid, 'station-1');

    await iterator.cancel();
  });
}
