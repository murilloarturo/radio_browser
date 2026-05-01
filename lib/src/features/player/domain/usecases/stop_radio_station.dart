import '../../../../core/result/result.dart';
import '../repositories/radio_player_repository.dart';

class StopRadioStation {
  const StopRadioStation(this._repository);

  final RadioPlayerRepository _repository;

  Future<Result<void>> call() {
    return _repository.stop();
  }
}
