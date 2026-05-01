import '../../../../core/network/radio_browser_api_client.dart';
import '../../../../core/network/radio_browser_api_exception.dart';
import '../../domain/entities/station_search_query.dart';
import '../models/resolved_station_stream_dto.dart';
import '../models/station_dto.dart';
import '../models/station_genre_dto.dart';

abstract interface class RadioBrowserRemoteDataSource {
  Future<List<StationDto>> getStations(StationSearchQuery query);

  Future<List<StationGenreDto>> getGenres();

  Future<ResolvedStationStreamDto> resolveStationStreamUrl(String stationUuid);

  Future<List<StationDto>> getStationsByUuids(List<String> stationUuids);
}

class DioRadioBrowserRemoteDataSource implements RadioBrowserRemoteDataSource {
  const DioRadioBrowserRemoteDataSource({
    required RadioBrowserApiClient apiClient,
  }) : _apiClient = apiClient;

  final RadioBrowserApiClient _apiClient;

  @override
  Future<List<StationDto>> getStations(StationSearchQuery query) async {
    final jsonList = await _apiClient.searchStations(query.toQueryParameters());
    return _parseList(jsonList, StationDto.fromJson, 'stations');
  }

  @override
  Future<List<StationGenreDto>> getGenres() async {
    final jsonList = await _apiClient.getTags();
    return _parseList(jsonList, StationGenreDto.fromJson, 'genres');
  }

  @override
  Future<ResolvedStationStreamDto> resolveStationStreamUrl(
    String stationUuid,
  ) async {
    final json = await _apiClient.resolveStationUrl(stationUuid);
    return _parseObject(
      json,
      ResolvedStationStreamDto.fromJson,
      'resolved station stream',
    );
  }

  @override
  Future<List<StationDto>> getStationsByUuids(List<String> stationUuids) async {
    if (stationUuids.isEmpty) {
      return const <StationDto>[];
    }

    final jsonList = await _apiClient.getStationsByUuids(stationUuids);
    return _parseList(jsonList, StationDto.fromJson, 'stations by UUID');
  }

  List<T> _parseList<T>(
    List<Map<String, dynamic>> jsonList,
    T Function(Map<String, dynamic> json) parser,
    String label,
  ) {
    try {
      return jsonList.map(parser).toList(growable: false);
    } on Object catch (error) {
      throw RadioBrowserDecodingException(
        'Unable to parse Radio Browser $label response.',
        cause: error,
      );
    }
  }

  T _parseObject<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) parser,
    String label,
  ) {
    try {
      return parser(json);
    } on Object catch (error) {
      throw RadioBrowserDecodingException(
        'Unable to parse Radio Browser $label response.',
        cause: error,
      );
    }
  }
}
