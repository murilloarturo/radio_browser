import '../../../../core/result/result.dart';
import '../entities/favorite_station.dart';

abstract interface class FavoritesRepository {
  Future<Result<List<FavoriteStation>>> getFavoriteStations();

  Stream<Result<List<FavoriteStation>>> watchFavoriteStations();

  Future<Result<void>> addFavoriteStation(FavoriteStation station);

  Future<Result<void>> removeFavoriteStation(String stationUuid);

  Future<Result<bool>> toggleFavoriteStation(FavoriteStation station);

  Future<Result<bool>> isFavoriteStation(String stationUuid);
}
