import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../domain/entities/radio_playback_snapshot.dart';
import '../../domain/repositories/radio_player_repository.dart';

class JustAudioRadioPlayerRepository implements RadioPlayerRepository {
  JustAudioRadioPlayerRepository({required AudioPlayer audioPlayer})
    : _audioPlayer = audioPlayer {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      _handlePlayerState,
      onError: _handlePlayerError,
    );
  }

  final AudioPlayer _audioPlayer;
  final StreamController<RadioPlaybackSnapshot> _controller =
      StreamController<RadioPlaybackSnapshot>.broadcast();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  RadioPlaybackSnapshot _currentSnapshot = const RadioPlaybackSnapshot.idle();
  Station? _currentStation;
  bool _audioSessionConfigured = false;

  @override
  RadioPlaybackSnapshot get currentSnapshot => _currentSnapshot;

  @override
  Stream<RadioPlaybackSnapshot> watchPlayback() async* {
    yield _currentSnapshot;
    yield* _controller.stream;
  }

  @override
  Future<Result<void>> play({
    required Station station,
    required String streamUrl,
  }) async {
    final streamUri = Uri.tryParse(streamUrl);
    if (streamUri == null || !streamUri.hasScheme) {
      return _fail(station, const UnavailableStationFailure());
    }

    try {
      _currentStation = station;
      _emit(
        RadioPlaybackSnapshot(
          status: RadioPlaybackStatus.loading,
          station: station,
        ),
      );

      await _configureAudioSession();
      await _audioPlayer.setAudioSource(AudioSource.uri(streamUri));
      unawaited(
        _audioPlayer.play().catchError((Object error) {
          _handlePlayerError(error);
        }),
      );

      return const Success<void>(null);
    } on Object catch (error) {
      return _fail(
        station,
        UnknownFailure(Localizable.playbackFailed.text, error),
      );
    }
  }

  @override
  Future<Result<void>> pause() async {
    try {
      await _audioPlayer.pause();
      return const Success<void>(null);
    } on Object catch (error) {
      return _fail(
        _currentStation,
        UnknownFailure(Localizable.playbackFailed.text, error),
      );
    }
  }

  @override
  Future<Result<void>> resume() async {
    if (_currentStation == null) {
      return const Failure<void>(UnavailableStationFailure());
    }

    try {
      await _configureAudioSession();
      unawaited(
        _audioPlayer.play().catchError((Object error) {
          _handlePlayerError(error);
        }),
      );
      return const Success<void>(null);
    } on Object catch (error) {
      return _fail(
        _currentStation,
        UnknownFailure(Localizable.playbackFailed.text, error),
      );
    }
  }

  @override
  Future<Result<void>> stop() async {
    try {
      await _audioPlayer.stop();
      _currentStation = null;
      _emit(const RadioPlaybackSnapshot.idle());
      return const Success<void>(null);
    } on Object catch (error) {
      return _fail(
        _currentStation,
        UnknownFailure(Localizable.playbackFailed.text, error),
      );
    }
  }

  @override
  Future<void> dispose() async {
    await _playerStateSubscription?.cancel();
    await _controller.close();
    await _audioPlayer.dispose();
  }

  Future<void> _configureAudioSession() async {
    if (_audioSessionConfigured) {
      return;
    }

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await session.setActive(true);
    _audioSessionConfigured = true;
  }

  void _handlePlayerState(PlayerState playerState) {
    final station = _currentStation;
    if (station == null) {
      return;
    }

    final status = switch (playerState.processingState) {
      ProcessingState.loading ||
      ProcessingState.buffering => RadioPlaybackStatus.loading,
      ProcessingState.completed => RadioPlaybackStatus.paused,
      _ =>
        playerState.playing
            ? RadioPlaybackStatus.playing
            : RadioPlaybackStatus.paused,
    };

    _emit(RadioPlaybackSnapshot(status: status, station: station));
  }

  void _handlePlayerError(Object error) {
    _emit(
      RadioPlaybackSnapshot(
        status: RadioPlaybackStatus.failure,
        station: _currentStation,
        failureMessage: Localizable.playbackFailed.text,
      ),
    );
  }

  Result<void> _fail(Station? station, AppFailure failure) {
    _emit(
      RadioPlaybackSnapshot(
        status: RadioPlaybackStatus.failure,
        station: station,
        failureMessage: failure.message,
      ),
    );
    return Failure<void>(failure);
  }

  void _emit(RadioPlaybackSnapshot snapshot) {
    _currentSnapshot = snapshot;
    if (!_controller.isClosed) {
      _controller.add(snapshot);
    }
  }
}
