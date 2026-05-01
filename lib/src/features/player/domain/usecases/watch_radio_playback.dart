import '../entities/radio_playback_snapshot.dart';
import '../repositories/radio_player_repository.dart';

class WatchRadioPlayback {
  const WatchRadioPlayback(this._repository);

  final RadioPlayerRepository _repository;

  Stream<RadioPlaybackSnapshot> call() {
    return _repository.watchPlayback();
  }
}
