import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../favorites/domain/entities/favorite_station.dart';

abstract interface class StationAiRepository {
  bool get isEnabled;

  Future<Result<List<String>>> rankStationUuids({
    required String prompt,
    required List<Station> candidateStations,
    required List<FavoriteStation> favoriteStations,
  });

  Future<Result<String>> transcribeAudio(String filePath);
}
