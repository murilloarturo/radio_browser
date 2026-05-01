import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../discover/domain/entities/station.dart';
import '../../../discover/domain/entities/station_search_query.dart';
import '../../../discover/domain/usecases/search_stations.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../../player/domain/usecases/pause_radio_station.dart';
import '../../../player/domain/usecases/play_radio_station.dart';
import '../../../player/domain/usecases/resume_radio_station.dart';
import '../../../player/domain/usecases/set_radio_volume.dart';
import '../../../player/domain/usecases/stop_radio_station.dart';
import '../../../player/domain/usecases/watch_radio_playback.dart';
import '../../domain/entities/favorite_station.dart';
import '../../domain/usecases/toggle_favorite_station.dart';
import '../../domain/usecases/watch_favorite_stations.dart';
import '../mappers/favorite_station_mapper.dart';
import '../mappers/station_favorite_mapper.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required WatchFavoriteStations watchFavoriteStations,
    required ToggleFavoriteStation toggleFavoriteStation,
    required SearchStations searchStations,
    required PlayRadioStation playRadioStation,
    required PauseRadioStation pauseRadioStation,
    required ResumeRadioStation resumeRadioStation,
    required SetRadioVolume setRadioVolume,
    required StopRadioStation stopRadioStation,
    required WatchRadioPlayback watchRadioPlayback,
  }) : _watchFavoriteStations = watchFavoriteStations,
       _toggleFavoriteStation = toggleFavoriteStation,
       _searchStations = searchStations,
       _playRadioStation = playRadioStation,
       _pauseRadioStation = pauseRadioStation,
       _resumeRadioStation = resumeRadioStation,
       _setRadioVolume = setRadioVolume,
       _stopRadioStation = stopRadioStation,
       _watchRadioPlayback = watchRadioPlayback,
       super(const FavoritesState());

  final WatchFavoriteStations _watchFavoriteStations;
  final ToggleFavoriteStation _toggleFavoriteStation;
  final SearchStations _searchStations;
  final PlayRadioStation _playRadioStation;
  final PauseRadioStation _pauseRadioStation;
  final ResumeRadioStation _resumeRadioStation;
  final SetRadioVolume _setRadioVolume;
  final StopRadioStation _stopRadioStation;
  final WatchRadioPlayback _watchRadioPlayback;

  StreamSubscription<Result<List<FavoriteStation>>>? _favoritesSubscription;
  StreamSubscription<RadioPlaybackSnapshot>? _playbackSubscription;
  String? _activeSimilarStationUuid;

  void load() {
    _watchFavorites();
    _watchPlayback();
    emit(
      state.copyWith(
        status: FavoritesStatus.loading,
        clearFailureMessage: true,
      ),
    );
  }

  Future<void> playStation(FavoriteStation favoriteStation) {
    return _playStation(favoriteStation.toStation());
  }

  Future<void> playSimilarStation(Station station) {
    return _playStation(station);
  }

  Future<void> removeFavorite(FavoriteStation favoriteStation) async {
    await _toggleFavoriteStation(favoriteStation);
  }

  Future<void> toggleFavorite(Station station) async {
    await _toggleFavoriteStation(station.toFavoriteStation());
  }

  Future<void> setVolume(double volume) async {
    final result = await _setRadioVolume(volume);
    result.when(
      success: (_) {},
      failure:
          (failure) => emit(
            state.copyWith(
              playbackStatus: RadioPlaybackStatus.failure,
              playbackFailureMessage: failure.message,
            ),
          ),
    );
  }

  Future<void> stopPlayback() async {
    final result = await _stopRadioStation();
    result.when(
      success: (_) {},
      failure:
          (failure) => emit(
            state.copyWith(
              playbackStatus: RadioPlaybackStatus.failure,
              playbackFailureMessage: failure.message,
            ),
          ),
    );
  }

  Future<void> toggleMiniPlayerPlayback() async {
    if (!state.hasMiniPlayer) {
      return;
    }

    if (state.playbackStatus == RadioPlaybackStatus.loading) {
      return;
    }

    if (state.playbackStatus == RadioPlaybackStatus.playing) {
      final result = await _pauseRadioStation();
      result.when(
        success: (_) {},
        failure:
            (failure) => emit(
              state.copyWith(
                playbackStatus: RadioPlaybackStatus.failure,
                playbackFailureMessage: failure.message,
              ),
            ),
      );
      return;
    }

    if (state.playbackStatus == RadioPlaybackStatus.paused) {
      final result = await _resumeRadioStation();
      result.when(
        success: (_) {},
        failure:
            (failure) => emit(
              state.copyWith(
                playbackStatus: RadioPlaybackStatus.failure,
                playbackFailureMessage: failure.message,
              ),
            ),
      );
      return;
    }

    await _playStation(state.activeStation!);
  }

  Future<void> _playStation(Station station) async {
    emit(
      state.copyWith(
        activeStation: station,
        playbackStatus: RadioPlaybackStatus.loading,
        similarStations: const <Station>[],
        clearPlaybackFailureMessage: true,
      ),
    );
    _activeSimilarStationUuid = station.stationUuid;
    unawaited(_loadSimilarStations(station));

    final result = await _playRadioStation(station);
    result.when(
      success: (_) {},
      failure:
          (failure) => emit(
            state.copyWith(
              activeStation: station,
              playbackStatus: RadioPlaybackStatus.failure,
              playbackFailureMessage: failure.message,
            ),
          ),
    );
  }

  void _watchFavorites() {
    _favoritesSubscription ??= _watchFavoriteStations().listen((result) {
      if (isClosed) {
        return;
      }

      result.when(
        success:
            (stations) => emit(
              state.copyWith(
                status: FavoritesStatus.success,
                stations: stations,
                clearFailureMessage: true,
              ),
            ),
        failure:
            (failure) => emit(
              state.copyWith(
                status: FavoritesStatus.failure,
                failureMessage: failure.message,
              ),
            ),
      );
    });
  }

  void _watchPlayback() {
    _playbackSubscription ??= _watchRadioPlayback().listen((snapshot) {
      if (isClosed) {
        return;
      }

      final station = snapshot.station;
      final shouldLoadSimilar =
          station != null && _activeSimilarStationUuid != station.stationUuid;

      if (station == null) {
        _activeSimilarStationUuid = null;
      } else if (shouldLoadSimilar) {
        _activeSimilarStationUuid = station.stationUuid;
        unawaited(_loadSimilarStations(station));
      }

      emit(
        state.copyWith(
          activeStation: station,
          clearActiveStation: station == null,
          playbackStatus: snapshot.status,
          volume: snapshot.volume,
          similarStations:
              station == null || shouldLoadSimilar ? const <Station>[] : null,
          playbackFailureMessage: snapshot.failureMessage,
          clearPlaybackFailureMessage: snapshot.failureMessage == null,
        ),
      );
    });
  }

  Future<void> _loadSimilarStations(Station station) async {
    final tag = station.tags.firstOrNull;
    if (tag == null) {
      if (!isClosed) {
        emit(state.copyWith(similarStations: const <Station>[]));
      }
      return;
    }

    final result = await _searchStations(
      StationSearchQuery(tag: tag, limit: 8),
    );

    if (isClosed || _activeSimilarStationUuid != station.stationUuid) {
      return;
    }

    result.when(
      success:
          (stations) => emit(
            state.copyWith(
              similarStations: stations
                  .where((item) => item.stationUuid != station.stationUuid)
                  .take(6)
                  .toList(growable: false),
            ),
          ),
      failure: (_) => emit(state.copyWith(similarStations: const <Station>[])),
    );
  }

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    await _playbackSubscription?.cancel();
    return super.close();
  }
}
