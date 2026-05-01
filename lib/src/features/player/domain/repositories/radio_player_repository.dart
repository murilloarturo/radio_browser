import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../entities/radio_playback_snapshot.dart';

abstract interface class RadioPlayerRepository {
  Stream<RadioPlaybackSnapshot> watchPlayback();

  RadioPlaybackSnapshot get currentSnapshot;

  Future<Result<void>> play({
    required Station station,
    required String streamUrl,
  });

  Future<Result<void>> pause();

  Future<Result<void>> resume();

  Future<Result<void>> setVolume(double volume);

  Future<Result<void>> stop();

  Future<void> dispose();
}
