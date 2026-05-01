import 'package:equatable/equatable.dart';

import '../../../discover/domain/entities/station.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../domain/entities/favorite_station.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.stations = const <FavoriteStation>[],
    this.similarStations = const <Station>[],
    this.failureMessage,
    this.activeStation,
    this.playbackStatus = RadioPlaybackStatus.idle,
    this.volume = 1,
    this.playbackFailureMessage,
  });

  final FavoritesStatus status;
  final List<FavoriteStation> stations;
  final List<Station> similarStations;
  final String? failureMessage;
  final Station? activeStation;
  final RadioPlaybackStatus playbackStatus;
  final double volume;
  final String? playbackFailureMessage;

  bool get isLoading => status == FavoritesStatus.loading;

  bool get hasStations => stations.isNotEmpty;

  bool get hasMiniPlayer => activeStation != null;

  bool get isPlaybackLoading => playbackStatus == RadioPlaybackStatus.loading;

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteStation>? stations,
    List<Station>? similarStations,
    String? failureMessage,
    bool clearFailureMessage = false,
    Station? activeStation,
    bool clearActiveStation = false,
    RadioPlaybackStatus? playbackStatus,
    double? volume,
    String? playbackFailureMessage,
    bool clearPlaybackFailureMessage = false,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      similarStations: similarStations ?? this.similarStations,
      failureMessage:
          clearFailureMessage ? null : failureMessage ?? this.failureMessage,
      activeStation:
          clearActiveStation ? null : activeStation ?? this.activeStation,
      playbackStatus: playbackStatus ?? this.playbackStatus,
      volume: volume ?? this.volume,
      playbackFailureMessage:
          clearPlaybackFailureMessage
              ? null
              : playbackFailureMessage ?? this.playbackFailureMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stations,
    similarStations,
    failureMessage,
    activeStation,
    playbackStatus,
    volume,
    playbackFailureMessage,
  ];
}
