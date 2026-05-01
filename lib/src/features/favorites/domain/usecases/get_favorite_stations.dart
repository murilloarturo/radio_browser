import '../../../../core/result/result.dart';
import '../entities/favorite_station.dart';
import '../repositories/favorites_repository.dart';

class GetFavoriteStations {
  const GetFavoriteStations(this._repository);

  final FavoritesRepository _repository;

  Future<Result<List<FavoriteStation>>> call() {
    return _repository.getFavoriteStations();
  }
}
