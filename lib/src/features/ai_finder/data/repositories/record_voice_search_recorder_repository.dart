import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/repositories/voice_search_recorder_repository.dart';

class RecordVoiceSearchRecorderRepository
    implements VoiceSearchRecorderRepository {
  RecordVoiceSearchRecorderRepository({AudioRecorder? audioRecorder})
    : _audioRecorder = audioRecorder ?? AudioRecorder();

  final AudioRecorder _audioRecorder;

  @override
  Future<Result<void>> start() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        return const Failure<void>(
          AiUnavailableFailure('Microphone permission is required.'),
        );
      }

      final temporaryDirectory = await getTemporaryDirectory();
      final path =
          '${temporaryDirectory.path}/radio_browser_voice_search_'
          '${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 44100,
          noiseSuppress: true,
          echoCancel: true,
        ),
        path: path,
      );

      return const Success<void>(null);
    } on Object catch (error) {
      return Failure<void>(
        UnknownFailure('Voice search could not start.', error),
      );
    }
  }

  @override
  Future<Result<String?>> stop() async {
    try {
      return Success<String?>(await _audioRecorder.stop());
    } on Object catch (error) {
      return Failure<String?>(
        UnknownFailure('Voice search could not stop.', error),
      );
    }
  }

  @override
  Future<Result<void>> cancel() async {
    try {
      await _audioRecorder.cancel();
      return const Success<void>(null);
    } on Object catch (error) {
      return Failure<void>(
        UnknownFailure('Voice search could not cancel.', error),
      );
    }
  }

  @override
  Future<void> dispose() {
    return _audioRecorder.dispose();
  }
}
