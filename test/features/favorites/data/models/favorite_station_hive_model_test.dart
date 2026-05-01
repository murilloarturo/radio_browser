import 'package:flutter_test/flutter_test.dart';
import 'package:radio_browser/src/features/favorites/data/models/favorite_station_hive_model.dart';

import '../../../../helpers/favorite_station_fixtures.dart';
import '../../../../helpers/hive_test_box.dart';

void main() {
  late HiveTestBox hive;

  setUp(() async {
    hive = await openHiveTestBox();
  });

  tearDown(() async {
    await hive.dispose();
  });

  test('round trips through Hive adapter', () async {
    final station = favoriteStationFixture();
    final model = FavoriteStationHiveModel.fromDomain(station);

    await hive.favoriteStationsBox.put(model.stationUuid, model);
    final storedModel = hive.favoriteStationsBox.get(station.stationUuid);

    expect(storedModel, isNotNull);
    expect(storedModel!.toDomain(), station);
  });
}
