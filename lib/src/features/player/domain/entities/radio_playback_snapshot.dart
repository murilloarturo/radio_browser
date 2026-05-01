import 'package:equatable/equatable.dart';

import '../../../discover/domain/entities/station.dart';

enum RadioPlaybackStatus { idle, loading, playing, paused, failure }

class RadioPlaybackSnapshot extends Equatable {
  const RadioPlaybackSnapshot({
    required this.status,
    this.volume = 1,
    this.station,
    this.failureMessage,
  });

  const RadioPlaybackSnapshot.idle()
    : status = RadioPlaybackStatus.idle,
      volume = 1,
      station = null,
      failureMessage = null;

  final RadioPlaybackStatus status;
  final double volume;
  final Station? station;
  final String? failureMessage;

  bool get isPlaying => status == RadioPlaybackStatus.playing;

  bool get isLoading => status == RadioPlaybackStatus.loading;

  RadioPlaybackSnapshot copyWith({
    RadioPlaybackStatus? status,
    double? volume,
    Station? station,
    bool clearStation = false,
    String? failureMessage,
    bool clearFailureMessage = false,
  }) {
    return RadioPlaybackSnapshot(
      status: status ?? this.status,
      volume: volume ?? this.volume,
      station: clearStation ? null : station ?? this.station,
      failureMessage:
          clearFailureMessage ? null : failureMessage ?? this.failureMessage,
    );
  }

  @override
  List<Object?> get props => [status, volume, station, failureMessage];
}
