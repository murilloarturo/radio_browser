import '../../../../core/result/result.dart';
import '../repositories/voice_search_recorder_repository.dart';

class StartVoiceSearchRecording {
  const StartVoiceSearchRecording(this._repository);

  final VoiceSearchRecorderRepository _repository;

  Future<Result<void>> call() {
    return _repository.start();
  }
}
