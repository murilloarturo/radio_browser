import '../../../../core/result/result.dart';
import '../entities/station.dart';
import '../repositories/station_repository.dart';

class GetStationsByUuids {
  const GetStationsByUuids(this._repository);

  final StationRepository _repository;

  Future<Result<List<Station>>> call(List<String> stationUuids) {
    return _repository.getStationsByUuids(stationUuids);
  }
}
