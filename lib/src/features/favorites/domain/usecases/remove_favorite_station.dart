import '../../../../core/result/result.dart';
import '../repositories/favorites_repository.dart';

class RemoveFavoriteStation {
  const RemoveFavoriteStation(this._repository);

  final FavoritesRepository _repository;

  Future<Result<void>> call(String stationUuid) {
    return _repository.removeFavoriteStation(stationUuid);
  }
}
