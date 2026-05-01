import 'package:equatable/equatable.dart';

import '../../../discover/domain/entities/station.dart';

enum RadioPlaybackStatus { idle, loading, playing, paused, failure }

class RadioPlaybackSnapshot extends Equatable {
  const RadioPlaybackSnapshot({
    required this.status,
    this.station,
    this.failureMessage,
  });

  const RadioPlaybackSnapshot.idle()
    : status = RadioPlaybackStatus.idle,
      station = null,
      failureMessage = null;

  final RadioPlaybackStatus status;
  final Station? station;
  final String? failureMessage;

  bool get isPlaying => status == RadioPlaybackStatus.playing;

  bool get isLoading => status == RadioPlaybackStatus.loading;

  @override
  List<Object?> get props => [status, station, failureMessage];
}
