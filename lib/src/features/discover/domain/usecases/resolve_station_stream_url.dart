import '../../../../core/result/result.dart';
import '../entities/resolved_station_stream.dart';
import '../repositories/station_repository.dart';

class ResolveStationStreamUrl {
  const ResolveStationStreamUrl(this._repository);

  final StationRepository _repository;

  Future<Result<ResolvedStationStream>> call(String stationUuid) {
    return _repository.resolveStationStreamUrl(stationUuid);
  }
}
