import '../../../../core/result/result.dart';
import '../repositories/radio_player_repository.dart';

class SetRadioVolume {
  const SetRadioVolume(this._repository);

  final RadioPlayerRepository _repository;

  Future<Result<void>> call(double volume) {
    return _repository.setVolume(volume);
  }
}
