import '../../../../core/result/result.dart';
import '../entities/favorite_station.dart';
import '../repositories/favorites_repository.dart';

class AddFavoriteStation {
  const AddFavoriteStation(this._repository);

  final FavoritesRepository _repository;

  Future<Result<void>> call(FavoriteStation station) {
    return _repository.addFavoriteStation(station);
  }
}
