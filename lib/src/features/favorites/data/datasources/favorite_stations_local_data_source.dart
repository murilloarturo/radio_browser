import 'dart:async';

import 'package:hive/hive.dart';

import '../models/favorite_station_hive_model.dart';

abstract interface class FavoriteStationsLocalDataSource {
  Future<List<FavoriteStationHiveModel>> getFavoriteStations();

  Stream<List<FavoriteStationHiveModel>> watchFavoriteStations();

  Future<void> saveFavoriteStation(FavoriteStationHiveModel station);

  Future<void> removeFavoriteStation(String stationUuid);

  Future<bool> containsFavoriteStation(String stationUuid);
}

class HiveFavoriteStationsLocalDataSource
    implements FavoriteStationsLocalDataSource {
  const HiveFavoriteStationsLocalDataSource({
    required Box<FavoriteStationHiveModel> box,
  }) : _box = box;

  static const boxName = 'favorite_stations';

  final Box<FavoriteStationHiveModel> _box;

  @override
  Future<List<FavoriteStationHiveModel>> getFavoriteStations() async {
    return _sortedFavorites();
  }

  @override
  Stream<List<FavoriteStationHiveModel>> watchFavoriteStations() {
    late StreamController<List<FavoriteStationHiveModel>> controller;
    StreamSubscription<BoxEvent>? subscription;

    controller = StreamController<List<FavoriteStationHiveModel>>(
      onListen: () {
        controller.add(_sortedFavorites());
        subscription = _box.watch().listen(
          (_) => controller.add(_sortedFavorites()),
          onError: controller.addError,
        );
      },
      onCancel: () => subscription?.cancel(),
    );

    return controller.stream;
  }

  @override
  Future<void> saveFavoriteStation(FavoriteStationHiveModel station) async {
    await _box.put(station.stationUuid, station);
  }

  @override
  Future<void> removeFavoriteStation(String stationUuid) async {
    await _box.delete(stationUuid);
  }

  @override
  Future<bool> containsFavoriteStation(String stationUuid) async {
    return _box.containsKey(stationUuid);
  }

  List<FavoriteStationHiveModel> _sortedFavorites() {
    return _box.values.toList(growable: false)
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));
  }
}
