import '../../../../core/result/result.dart';
import '../repositories/radio_player_repository.dart';

class ResumeRadioStation {
  const ResumeRadioStation(this._repository);

  final RadioPlayerRepository _repository;

  Future<Result<void>> call() {
    return _repository.resume();
  }
}
