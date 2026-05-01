import 'dart:io';

import 'package:hive/hive.dart';
import 'package:radio_browser/src/features/favorites/data/datasources/favorite_stations_local_data_source.dart';
import 'package:radio_browser/src/features/favorites/data/models/favorite_station_hive_model.dart';

class HiveTestBox {
  const HiveTestBox({
    required this.directory,
    required this.favoriteStationsBox,
  });

  final Directory directory;
  final Box<FavoriteStationHiveModel> favoriteStationsBox;

  Future<void> dispose() async {
    await Hive.close();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }
}

Future<HiveTestBox> openHiveTestBox() async {
  final directory = await Directory.systemTemp.createTemp(
    'radio_browser_hive_test_',
  );

  Hive.init(directory.path);
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(FavoriteStationHiveModelAdapter());
  }

  final box = await Hive.openBox<FavoriteStationHiveModel>(
    HiveFavoriteStationsLocalDataSource.boxName,
  );

  return HiveTestBox(directory: directory, favoriteStationsBox: box);
}
