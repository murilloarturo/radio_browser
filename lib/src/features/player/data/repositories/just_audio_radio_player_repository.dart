import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

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
  double _volume = 1;
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
          volume: _volume,
          station: station,
        ),
      );

      await _configureAudioSession();
      await _audioPlayer.setAudioSource(
        AudioSource.uri(streamUri, tag: _mediaItemFor(station)),
      );
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
  Future<Result<void>> setVolume(double volume) async {
    final normalizedVolume = volume.clamp(0.0, 1.0).toDouble();
    try {
      _volume = normalizedVolume;
      await _audioPlayer.setVolume(normalizedVolume);
      _emit(_currentSnapshot.copyWith(volume: normalizedVolume));
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
      _emit(
        RadioPlaybackSnapshot(
          status: RadioPlaybackStatus.idle,
          volume: _volume,
        ),
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

  MediaItem _mediaItemFor(Station station) {
    return MediaItem(
      id: station.stationUuid,
      album: Localizable.appTitle.text,
      title: station.name,
      artist: _stationSubtitle(station),
      artUri: _stationArtworkUri(station),
    );
  }

  Uri? _stationArtworkUri(Station station) {
    final faviconUrl = station.faviconUrl;
    if (faviconUrl == null || faviconUrl.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(faviconUrl);
    return uri != null && uri.hasScheme ? uri : null;
  }

  String _stationSubtitle(Station station) {
    final parts = <String>[
      if (station.countryCode != null && station.countryCode!.isNotEmpty)
        station.countryCode!,
      if (station.language != null && station.language!.isNotEmpty)
        station.language!,
    ];

    if (parts.isEmpty) {
      return Localizable.appTitle.text;
    }

    return parts.join(Localizable.metadataSeparator.text);
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

    _emit(
      RadioPlaybackSnapshot(status: status, volume: _volume, station: station),
    );
  }

  void _handlePlayerError(Object error) {
    _emit(
      RadioPlaybackSnapshot(
        status: RadioPlaybackStatus.failure,
        volume: _volume,
        station: _currentStation,
        failureMessage: Localizable.playbackFailed.text,
      ),
    );
  }

  Result<void> _fail(Station? station, AppFailure failure) {
    _emit(
      RadioPlaybackSnapshot(
        status: RadioPlaybackStatus.failure,
        volume: _volume,
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
