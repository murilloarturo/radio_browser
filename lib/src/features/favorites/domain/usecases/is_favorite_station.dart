import '../../../../core/result/result.dart';
import '../repositories/favorites_repository.dart';

class IsFavoriteStation {
  const IsFavoriteStation(this._repository);

  final FavoritesRepository _repository;

  Future<Result<bool>> call(String stationUuid) {
    return _repository.isFavoriteStation(stationUuid);
  }
}
