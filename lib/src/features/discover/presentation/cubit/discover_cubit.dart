import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/result/result.dart';
import '../../../favorites/domain/entities/favorite_station.dart';
import '../../../favorites/domain/usecases/toggle_favorite_station.dart';
import '../../../favorites/domain/usecases/watch_favorite_stations.dart';
import '../../../favorites/presentation/mappers/station_favorite_mapper.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../../player/domain/usecases/pause_radio_station.dart';
import '../../../player/domain/usecases/play_radio_station.dart';
import '../../../player/domain/usecases/resume_radio_station.dart';
import '../../../player/domain/usecases/watch_radio_playback.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/station_search_query.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/get_stations.dart';
import '../../domain/usecases/search_stations.dart';
import 'discover_filter.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({
    required GetStations getStations,
    required SearchStations searchStations,
    required GetGenres getGenres,
    required WatchFavoriteStations watchFavoriteStations,
    required ToggleFavoriteStation toggleFavoriteStation,
    required PlayRadioStation playRadioStation,
    required PauseRadioStation pauseRadioStation,
    required ResumeRadioStation resumeRadioStation,
    required WatchRadioPlayback watchRadioPlayback,
  }) : _getStations = getStations,
       _searchStations = searchStations,
       _getGenres = getGenres,
       _watchFavoriteStations = watchFavoriteStations,
       _toggleFavoriteStation = toggleFavoriteStation,
       _playRadioStation = playRadioStation,
       _pauseRadioStation = pauseRadioStation,
       _resumeRadioStation = resumeRadioStation,
       _watchRadioPlayback = watchRadioPlayback,
       super(const DiscoverState());

  final GetStations _getStations;
  final SearchStations _searchStations;
  final GetGenres _getGenres;
  final WatchFavoriteStations _watchFavoriteStations;
  final ToggleFavoriteStation _toggleFavoriteStation;
  final PlayRadioStation _playRadioStation;
  final PauseRadioStation _pauseRadioStation;
  final ResumeRadioStation _resumeRadioStation;
  final WatchRadioPlayback _watchRadioPlayback;

  StreamSubscription<Result<List<FavoriteStation>>>? _favoritesSubscription;
  StreamSubscription<RadioPlaybackSnapshot>? _playbackSubscription;

  Future<void> load() async {
    _watchFavorites();
    _watchPlayback();
    emit(
      state.copyWith(status: DiscoverStatus.loading, clearFailureMessage: true),
    );

    final genresResult = await _getGenres();
    genresResult.when(
      success: (genres) => emit(state.copyWith(genres: genres)),
      failure: (_) {},
    );

    await _loadStations(state.activeFilter.query);
  }

  Future<void> refresh() {
    return _loadStations(_queryForCurrentSelection());
  }

  Future<void> selectFilter(DiscoverFilter filter) async {
    emit(
      state.copyWith(
        activeFilter: filter,
        searchTerm: '',
        status: DiscoverStatus.loading,
        clearFailureMessage: true,
      ),
    );

    await _loadStations(filter.query);
  }

  Future<void> search(String term) async {
    final normalizedTerm = term.trim();
    emit(
      state.copyWith(
        searchTerm: normalizedTerm,
        status: DiscoverStatus.loading,
        clearFailureMessage: true,
      ),
    );

    await _loadStations(
      _queryForCurrentSelection(
        name: normalizedTerm.isEmpty ? null : normalizedTerm,
      ),
    );
  }

  Future<void> playStation(Station station) async {
    emit(
      state.copyWith(
        activeStation: station,
        playbackStatus: RadioPlaybackStatus.loading,
        clearPlaybackFailureMessage: true,
      ),
    );

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

    await playStation(state.activeStation!);
  }

  Future<void> toggleFavorite(Station station) async {
    await _toggleFavoriteStation(station.toFavoriteStation());
  }

  bool isFavorite(String stationUuid) {
    return state.favoriteStationUuids.contains(stationUuid);
  }

  Future<void> _loadStations(StationSearchQuery query) async {
    final result =
        state.searchTerm.isEmpty && query.name == null
            ? await _getStations(query: query)
            : await _searchStations(query);

    result.when(
      success:
          (stations) => emit(
            state.copyWith(
              status: DiscoverStatus.success,
              stations: stations,
              clearFailureMessage: true,
            ),
          ),
      failure:
          (failure) => emit(
            state.copyWith(
              status: DiscoverStatus.failure,
              failureMessage: failure.message,
              failureKind:
                  failure is NetworkFailure
                      ? DiscoverFailureKind.network
                      : DiscoverFailureKind.unknown,
            ),
          ),
    );
  }

  StationSearchQuery _queryForCurrentSelection({String? name}) {
    final selectedQuery = state.activeFilter.query;
    return StationSearchQuery(
      name: name ?? (state.searchTerm.isEmpty ? null : state.searchTerm),
      tag: selectedQuery.tag,
      countryCode: selectedQuery.countryCode,
      language: selectedQuery.language,
      limit: selectedQuery.limit,
      offset: selectedQuery.offset,
      hideBroken: selectedQuery.hideBroken,
      order: selectedQuery.order,
      reverse: selectedQuery.reverse,
    );
  }

  void _watchFavorites() {
    _favoritesSubscription ??= _watchFavoriteStations().listen((result) {
      result.when(
        success: (favorites) {
          if (!isClosed) {
            emit(state.copyWith(favoriteStations: favorites));
          }
        },
        failure: (_) {},
      );
    });
  }

  void _watchPlayback() {
    _playbackSubscription ??= _watchRadioPlayback().listen((snapshot) {
      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
          activeStation: snapshot.station,
          clearActiveStation: snapshot.station == null,
          playbackStatus: snapshot.status,
          playbackFailureMessage: snapshot.failureMessage,
          clearPlaybackFailureMessage: snapshot.failureMessage == null,
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    await _playbackSubscription?.cancel();
    return super.close();
  }
}
