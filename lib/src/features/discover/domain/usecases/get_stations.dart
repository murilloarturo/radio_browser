import '../../../../core/result/result.dart';
import '../entities/station.dart';
import '../entities/station_search_query.dart';
import '../repositories/station_repository.dart';

class GetStations {
  const GetStations(this._repository);

  final StationRepository _repository;

  Future<Result<List<Station>>> call({
    StationSearchQuery query = const StationSearchQuery(),
  }) {
    return _repository.getStations(query: query);
  }
}
