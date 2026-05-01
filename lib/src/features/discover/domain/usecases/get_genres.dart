import '../../../../core/result/result.dart';
import '../entities/station_genre.dart';
import '../repositories/station_repository.dart';

class GetGenres {
  const GetGenres(this._repository);

  final StationRepository _repository;

  Future<Result<List<StationGenre>>> call() {
    return _repository.getGenres();
  }
}
