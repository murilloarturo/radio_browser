import '../../../../core/result/result.dart';
import '../entities/favorite_station.dart';
import '../repositories/favorites_repository.dart';

class WatchFavoriteStations {
  const WatchFavoriteStations(this._repository);

  final FavoritesRepository _repository;

  Stream<Result<List<FavoriteStation>>> call() {
    return _repository.watchFavoriteStations();
  }
}
