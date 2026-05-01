import '../../../../core/result/result.dart';
import '../entities/resolved_station_stream.dart';
import '../entities/station.dart';
import '../entities/station_genre.dart';
import '../entities/station_search_query.dart';

abstract interface class StationRepository {
  Future<Result<List<Station>>> getStations({
    StationSearchQuery query = const StationSearchQuery(),
  });

  Future<Result<List<Station>>> searchStations(StationSearchQuery query);

  Future<Result<List<StationGenre>>> getGenres();

  Future<Result<ResolvedStationStream>> resolveStationStreamUrl(
    String stationUuid,
  );

  Future<Result<List<Station>>> getStationsByUuids(List<String> stationUuids);
}
