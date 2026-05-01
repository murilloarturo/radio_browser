import '../../../../core/result/result.dart';
import '../repositories/station_ai_repository.dart';

class TranscribeStationSearch {
  const TranscribeStationSearch(this._repository);

  final StationAiRepository _repository;

  bool get isEnabled => _repository.isEnabled;

  Future<Result<String>> call(String filePath) {
    return _repository.transcribeAudio(filePath);
  }
}
