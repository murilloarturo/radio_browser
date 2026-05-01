import '../../../../core/result/result.dart';
import '../entities/station.dart';
import '../entities/station_search_query.dart';
import '../repositories/station_repository.dart';

class SearchStations {
  const SearchStations(this._repository);

  final StationRepository _repository;

  Future<Result<List<Station>>> call(StationSearchQuery query) {
    return _repository.searchStations(query);
  }
}
