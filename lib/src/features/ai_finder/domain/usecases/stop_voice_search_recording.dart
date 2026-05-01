import '../../../../core/result/result.dart';
import '../repositories/voice_search_recorder_repository.dart';

class StopVoiceSearchRecording {
  const StopVoiceSearchRecording(this._repository);

  final VoiceSearchRecorderRepository _repository;

  Future<Result<String?>> call() {
    return _repository.stop();
  }
}
