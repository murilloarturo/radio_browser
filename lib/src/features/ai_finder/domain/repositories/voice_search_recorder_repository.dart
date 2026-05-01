import '../../../../core/result/result.dart';

abstract interface class VoiceSearchRecorderRepository {
  Future<Result<void>> start();

  Future<Result<String?>> stop();

  Future<Result<void>> cancel();

  Future<void> dispose();
}
