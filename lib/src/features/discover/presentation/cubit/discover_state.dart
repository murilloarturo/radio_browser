import 'package:equatable/equatable.dart';

import '../../../favorites/domain/entities/favorite_station.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/station_genre.dart';
import 'discover_filter.dart';

enum DiscoverStatus { initial, loading, success, failure }

class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.stations = const <Station>[],
    this.genres = const <StationGenre>[],
    this.favoriteStations = const <FavoriteStation>[],
    this.activeFilter = DiscoverFilter.popular,
    this.searchTerm = '',
    this.failureMessage,
    this.activeStation,
    this.playbackStatus = RadioPlaybackStatus.idle,
    this.playbackFailureMessage,
  });

  final DiscoverStatus status;
  final List<Station> stations;
  final List<StationGenre> genres;
  final List<FavoriteStation> favoriteStations;
  final DiscoverFilter activeFilter;
  final String searchTerm;
  final String? failureMessage;
  final Station? activeStation;
  final RadioPlaybackStatus playbackStatus;
  final String? playbackFailureMessage;

  bool get isLoading => status == DiscoverStatus.loading;

  bool get hasStations => stations.isNotEmpty;

  bool get hasMiniPlayer => activeStation != null;

  bool get isMiniPlayerPlaying => playbackStatus == RadioPlaybackStatus.playing;

  bool get isPlaybackLoading => playbackStatus == RadioPlaybackStatus.loading;

  Set<String> get favoriteStationUuids {
    return favoriteStations.map((station) => station.stationUuid).toSet();
  }

  Station? get recommendedStation {
    if (stations.isEmpty) {
      return null;
    }

    return stations.first;
  }

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Station>? stations,
    List<StationGenre>? genres,
    List<FavoriteStation>? favoriteStations,
    DiscoverFilter? activeFilter,
    String? searchTerm,
    String? failureMessage,
    bool clearFailureMessage = false,
    Station? activeStation,
    bool clearActiveStation = false,
    RadioPlaybackStatus? playbackStatus,
    String? playbackFailureMessage,
    bool clearPlaybackFailureMessage = false,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      genres: genres ?? this.genres,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      activeFilter: activeFilter ?? this.activeFilter,
      searchTerm: searchTerm ?? this.searchTerm,
      failureMessage:
          clearFailureMessage ? null : failureMessage ?? this.failureMessage,
      activeStation:
          clearActiveStation ? null : activeStation ?? this.activeStation,
      playbackStatus: playbackStatus ?? this.playbackStatus,
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
    genres,
    favoriteStations,
    activeFilter,
    searchTerm,
    failureMessage,
    activeStation,
    playbackStatus,
    playbackFailureMessage,
  ];
}
