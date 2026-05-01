import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/favorite_station.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorite_stations_local_data_source.dart';
import '../models/favorite_station_hive_model.dart';

class HiveFavoritesRepository implements FavoritesRepository {
  const HiveFavoritesRepository({
    required FavoriteStationsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final FavoriteStationsLocalDataSource _localDataSource;

  @override
  Future<Result<List<FavoriteStation>>> getFavoriteStations() {
    return _guard(() async {
      final favorites = await _localDataSource.getFavoriteStations();
      return favorites.map((favorite) => favorite.toDomain()).toList();
    });
  }

  @override
  Stream<Result<List<FavoriteStation>>> watchFavoriteStations() async* {
    try {
      await for (final favorites in _localDataSource.watchFavoriteStations()) {
        yield Success<List<FavoriteStation>>(
          favorites.map((favorite) => favorite.toDomain()).toList(),
        );
      }
    } on Object catch (error) {
      yield Failure<List<FavoriteStation>>(
        PersistenceFailure('Unable to watch favorite stations.', error),
      );
    }
  }

  @override
  Future<Result<void>> addFavoriteStation(FavoriteStation station) {
    return _guard(() async {
      final isFavorite = await _localDataSource.containsFavoriteStation(
        station.stationUuid,
      );
      if (isFavorite) {
        return;
      }

      await _localDataSource.saveFavoriteStation(
        FavoriteStationHiveModel.fromDomain(station),
      );
    });
  }

  @override
  Future<Result<void>> removeFavoriteStation(String stationUuid) {
    return _guard(() => _localDataSource.removeFavoriteStation(stationUuid));
  }

  @override
  Future<Result<bool>> toggleFavoriteStation(FavoriteStation station) {
    return _guard(() async {
      final isFavorite = await _localDataSource.containsFavoriteStation(
        station.stationUuid,
      );
      if (isFavorite) {
        await _localDataSource.removeFavoriteStation(station.stationUuid);
        return false;
      }

      await _localDataSource.saveFavoriteStation(
        FavoriteStationHiveModel.fromDomain(station),
      );
      return true;
    });
  }

  @override
  Future<Result<bool>> isFavoriteStation(String stationUuid) {
    return _guard(() => _localDataSource.containsFavoriteStation(stationUuid));
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on Object catch (error) {
      return Failure<T>(
        PersistenceFailure('Unable to access favorite stations.', error),
      );
    }
  }
}
