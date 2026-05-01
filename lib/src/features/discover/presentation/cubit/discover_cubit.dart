import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../favorites/domain/entities/favorite_station.dart';
import '../../../favorites/domain/usecases/toggle_favorite_station.dart';
import '../../../favorites/domain/usecases/watch_favorite_stations.dart';
import '../../domain/entities/station.dart';
import '../../domain/entities/station_search_query.dart';
import '../../domain/usecases/get_genres.dart';
import '../../domain/usecases/get_stations.dart';
import '../../domain/usecases/search_stations.dart';
import '../mappers/favorite_station_mapper.dart';
import 'discover_filter.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({
    required GetStations getStations,
    required SearchStations searchStations,
    required GetGenres getGenres,
    required WatchFavoriteStations watchFavoriteStations,
    required ToggleFavoriteStation toggleFavoriteStation,
  }) : _getStations = getStations,
       _searchStations = searchStations,
       _getGenres = getGenres,
       _watchFavoriteStations = watchFavoriteStations,
       _toggleFavoriteStation = toggleFavoriteStation,
       super(const DiscoverState());

  final GetStations _getStations;
  final SearchStations _searchStations;
  final GetGenres _getGenres;
  final WatchFavoriteStations _watchFavoriteStations;
  final ToggleFavoriteStation _toggleFavoriteStation;

  StreamSubscription<Result<List<FavoriteStation>>>? _favoritesSubscription;

  Future<void> load() async {
    _watchFavorites();
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

  void playStation(Station station) {
    emit(state.copyWith(activeStation: station, isMiniPlayerPlaying: true));
  }

  void toggleMiniPlayerPlayback() {
    if (!state.hasMiniPlayer) {
      return;
    }

    emit(state.copyWith(isMiniPlayerPlaying: !state.isMiniPlayerPlaying));
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

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
