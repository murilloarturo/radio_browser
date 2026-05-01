import '../../../../core/result/result.dart';
import '../entities/favorite_station.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavoriteStation {
  const ToggleFavoriteStation(this._repository);

  final FavoritesRepository _repository;

  Future<Result<bool>> call(FavoriteStation station) {
    return _repository.toggleFavoriteStation(station);
  }
}
