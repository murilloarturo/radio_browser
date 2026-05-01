import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../favorites/domain/entities/favorite_station.dart';
import '../repositories/station_ai_repository.dart';

class RankStationsWithAi {
  const RankStationsWithAi(this._repository);

  final StationAiRepository _repository;

  bool get isEnabled => _repository.isEnabled;

  Future<Result<List<Station>>> call({
    required String prompt,
    required List<Station> candidateStations,
    List<FavoriteStation> favoriteStations = const <FavoriteStation>[],
  }) async {
    if (!isEnabled || candidateStations.isEmpty) {
      return Success<List<Station>>(candidateStations);
    }

    final result = await _repository.rankStationUuids(
      prompt: prompt,
      candidateStations: candidateStations,
      favoriteStations: favoriteStations,
    );

    return result.when(
      success:
          (stationUuids) => Success<List<Station>>(
            _orderedStations(
              candidateStations: candidateStations,
              stationUuids: stationUuids,
            ),
          ),
      failure: (failure) => Failure<List<Station>>(failure),
    );
  }

  List<Station> _orderedStations({
    required List<Station> candidateStations,
    required List<String> stationUuids,
  }) {
    final stationsByUuid = <String, Station>{
      for (final station in candidateStations) station.stationUuid: station,
    };
    final seenStationUuids = <String>{};
    final orderedStations = <Station>[];

    for (final stationUuid in stationUuids) {
      final station = stationsByUuid[stationUuid];
      if (station != null && seenStationUuids.add(station.stationUuid)) {
        orderedStations.add(station);
      }
    }

    for (final station in candidateStations) {
      if (seenStationUuids.add(station.stationUuid)) {
        orderedStations.add(station);
      }
    }

    return orderedStations;
  }
}
