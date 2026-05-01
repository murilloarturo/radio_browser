import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/resolved_station_stream.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/station_genre.dart';
import '../../domain/entities/station_search_query.dart';
import '../../domain/repositories/station_repository.dart';
import '../datasources/radio_browser_remote_data_source.dart';
import 'radio_browser_failure_mapper.dart';

class RadioBrowserStationRepository implements StationRepository {
  const RadioBrowserStationRepository({
    required RadioBrowserRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final RadioBrowserRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Station>>> getStations({
    StationSearchQuery query = const StationSearchQuery(),
  }) {
    return _guard(() async {
      final stationDtos = await _remoteDataSource.getStations(query);
      return stationDtos.map((station) => station.toDomain()).toList();
    });
  }

  @override
  Future<Result<List<Station>>> searchStations(StationSearchQuery query) {
    return getStations(query: query);
  }

  @override
  Future<Result<List<StationGenre>>> getGenres() {
    return _guard(() async {
      final genreDtos = await _remoteDataSource.getGenres();
      return genreDtos.map((genre) => genre.toDomain()).toList();
    });
  }

  @override
  Future<Result<ResolvedStationStream>> resolveStationStreamUrl(
    String stationUuid,
  ) async {
    try {
      final streamDto = await _remoteDataSource.resolveStationStreamUrl(
        stationUuid,
      );
      if (!streamDto.ok || streamDto.url.trim().isEmpty) {
        return Failure<ResolvedStationStream>(
          UnavailableStationFailure(
            streamDto.message.trim().isEmpty
                ? 'This station is unavailable.'
                : streamDto.message,
          ),
        );
      }

      return Success<ResolvedStationStream>(streamDto.toDomain());
    } on Object catch (error) {
      return Failure<ResolvedStationStream>(mapRadioBrowserFailure(error));
    }
  }

  @override
  Future<Result<List<Station>>> getStationsByUuids(List<String> stationUuids) {
    return _guard(() async {
      final stationDtos = await _remoteDataSource.getStationsByUuids(
        stationUuids,
      );
      return stationDtos.map((station) => station.toDomain()).toList();
    });
  }

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success<T>(await action());
    } on Object catch (error) {
      return Failure<T>(mapRadioBrowserFailure(error));
    }
  }
}
