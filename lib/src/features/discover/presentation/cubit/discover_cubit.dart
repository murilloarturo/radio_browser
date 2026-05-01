import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/network/open_ai_api_logger.dart';
import '../../../../core/result/result.dart';
import '../../../ai_finder/domain/usecases/rank_stations_with_ai.dart';
import '../../../ai_finder/domain/usecases/start_voice_search_recording.dart';
import '../../../ai_finder/domain/usecases/stop_voice_search_recording.dart';
import '../../../ai_finder/domain/usecases/transcribe_station_search.dart';
import '../../../favorites/domain/entities/favorite_station.dart';
import '../../../favorites/domain/usecases/toggle_favorite_station.dart';
import '../../../favorites/domain/usecases/watch_favorite_stations.dart';
import '../../../favorites/presentation/mappers/station_favorite_mapper.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../../player/domain/usecases/pause_radio_station.dart';
import '../../../player/domain/usecases/play_radio_station.dart';
import '../../../player/domain/usecases/resume_radio_station.dart';
import '../../../player/domain/usecases/set_radio_volume.dart';
import '../../../player/domain/usecases/stop_radio_station.dart';
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
    required RankStationsWithAi rankStationsWithAi,
    required StartVoiceSearchRecording startVoiceSearchRecording,
    required StopVoiceSearchRecording stopVoiceSearchRecording,
    required TranscribeStationSearch transcribeStationSearch,
    required WatchFavoriteStations watchFavoriteStations,
    required ToggleFavoriteStation toggleFavoriteStation,
    required PlayRadioStation playRadioStation,
    required PauseRadioStation pauseRadioStation,
    required ResumeRadioStation resumeRadioStation,
    required SetRadioVolume setRadioVolume,
    required StopRadioStation stopRadioStation,
    required WatchRadioPlayback watchRadioPlayback,
  }) : _getStations = getStations,
       _searchStations = searchStations,
       _getGenres = getGenres,
       _rankStationsWithAi = rankStationsWithAi,
       _startVoiceSearchRecording = startVoiceSearchRecording,
       _stopVoiceSearchRecording = stopVoiceSearchRecording,
       _transcribeStationSearch = transcribeStationSearch,
       _watchFavoriteStations = watchFavoriteStations,
       _toggleFavoriteStation = toggleFavoriteStation,
       _playRadioStation = playRadioStation,
       _pauseRadioStation = pauseRadioStation,
       _resumeRadioStation = resumeRadioStation,
       _setRadioVolume = setRadioVolume,
       _stopRadioStation = stopRadioStation,
       _watchRadioPlayback = watchRadioPlayback,
       super(const DiscoverState());

  final GetStations _getStations;
  final SearchStations _searchStations;
  final GetGenres _getGenres;
  final RankStationsWithAi _rankStationsWithAi;
  final StartVoiceSearchRecording _startVoiceSearchRecording;
  final StopVoiceSearchRecording _stopVoiceSearchRecording;
  final TranscribeStationSearch _transcribeStationSearch;
  final WatchFavoriteStations _watchFavoriteStations;
  final ToggleFavoriteStation _toggleFavoriteStation;
  final PlayRadioStation _playRadioStation;
  final PauseRadioStation _pauseRadioStation;
  final ResumeRadioStation _resumeRadioStation;
  final SetRadioVolume _setRadioVolume;
  final StopRadioStation _stopRadioStation;
  final WatchRadioPlayback _watchRadioPlayback;

  StreamSubscription<Result<List<FavoriteStation>>>? _favoritesSubscription;
  StreamSubscription<RadioPlaybackSnapshot>? _playbackSubscription;

  Future<void> load() async {
    _watchFavorites();
    _watchPlayback();
    emit(
      state.copyWith(
        status: DiscoverStatus.loading,
        aiRecommendationStatus: _pendingAiRecommendationStatus(),
        clearFailureMessage: true,
      ),
    );

    final genresResult = await _getGenres();
    genresResult.when(
      success: (genres) => emit(state.copyWith(genres: genres)),
      failure: (_) {},
    );

    await _loadStations(state.activeFilter.query);
  }

  Future<void> refresh() {
    emit(
      state.copyWith(
        status: DiscoverStatus.loading,
        aiRecommendationStatus: _pendingAiRecommendationStatus(),
        clearFailureMessage: true,
      ),
    );

    if (state.searchTerm.trim().isNotEmpty && _rankStationsWithAi.isEnabled) {
      return _loadAiSearchStations(state.searchTerm);
    }

    return _loadStations(_queryForCurrentSelection());
  }

  Future<void> selectFilter(DiscoverFilter filter) async {
    emit(
      state.copyWith(
        activeFilter: filter,
        searchTerm: '',
        status: DiscoverStatus.loading,
        aiRecommendationStatus: _pendingAiRecommendationStatus(),
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
        aiRecommendationStatus: _pendingAiRecommendationStatus(),
        clearFailureMessage: true,
      ),
    );

    if (normalizedTerm.isEmpty || !_rankStationsWithAi.isEnabled) {
      await _loadStations(
        _queryForCurrentSelection(
          name: normalizedTerm.isEmpty ? null : normalizedTerm,
        ),
      );
      return;
    }

    await _loadAiSearchStations(normalizedTerm);
  }

  Future<void> toggleVoiceSearch() async {
    if (state.isVoiceSearchProcessing) {
      return;
    }

    if (!state.isVoiceSearchRecording && !_transcribeStationSearch.isEnabled) {
      logOpenAiApi('Voice search skipped: OPENAI_API_KEY was not provided.');
      emit(
        state.copyWith(aiFailureMessage: Localizable.aiSearchUnavailable.text),
      );
      return;
    }

    if (state.isVoiceSearchRecording) {
      await _finishVoiceSearch();
      return;
    }

    final result = await _startVoiceSearchRecording();
    switch (result) {
      case Success<void>():
        emit(
          state.copyWith(
            isVoiceSearchRecording: true,
            clearAiFailureMessage: true,
          ),
        );
      case Failure<void>(failure: final failure):
        emit(state.copyWith(aiFailureMessage: failure.message));
    }
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

  bool isFavorite(String stationUuid) {
    return state.favoriteStationUuids.contains(stationUuid);
  }

  Future<void> _loadStations(StationSearchQuery query) async {
    final result =
        state.searchTerm.isEmpty && query.name == null
            ? await _getStations(query: query)
            : await _searchStations(query);

    switch (result) {
      case Success<List<Station>>(value: final stations):
        final rankResult = await _rankStationsForCurrentContext(
          stations: stations,
          query: query,
        );
        emit(
          state.copyWith(
            status: DiscoverStatus.success,
            stations: rankResult.stations,
            aiRecommendationStatus: _resolvedAiRecommendationStatus(rankResult),
            aiFailureMessage: rankResult.failure?.message,
            clearAiFailureMessage: rankResult.failure == null,
            clearFailureMessage: true,
          ),
        );
      case Failure<List<Station>>(failure: final failure):
        _emitStationFailure(failure);
    }
  }

  Future<void> _loadAiSearchStations(String prompt) async {
    final namedResult = await _searchStations(
      _queryForCurrentSelection(name: prompt),
    );
    final broadResult = await _getStations(
      query: _queryForCurrentSelection(name: null, limit: 80),
    );

    final stations = <Station>[];
    AppFailure? failure;

    switch (namedResult) {
      case Success<List<Station>>(value: final namedStations):
        stations.addAll(namedStations);
      case Failure<List<Station>>(failure: final resultFailure):
        failure = resultFailure;
    }

    switch (broadResult) {
      case Success<List<Station>>(value: final broadStations):
        stations.addAll(broadStations);
      case Failure<List<Station>>(failure: final resultFailure):
        failure ??= resultFailure;
    }

    final candidateStations = _uniqueStations(stations);
    if (candidateStations.isEmpty) {
      if (failure != null) {
        _emitStationFailure(failure);
        return;
      }

      emit(
        state.copyWith(
          status: DiscoverStatus.success,
          stations: const <Station>[],
          aiRecommendationStatus: AiRecommendationStatus.unavailable,
          clearFailureMessage: true,
        ),
      );
      return;
    }

    final rankResult = await _rankStationsForPrompt(
      prompt: prompt,
      stations: candidateStations,
    );

    emit(
      state.copyWith(
        status: DiscoverStatus.success,
        stations: rankResult.stations,
        aiRecommendationStatus: _resolvedAiRecommendationStatus(rankResult),
        aiFailureMessage: rankResult.failure?.message,
        clearAiFailureMessage: rankResult.failure == null,
        clearFailureMessage: true,
      ),
    );
  }

  Future<void> _finishVoiceSearch() async {
    emit(
      state.copyWith(
        isVoiceSearchRecording: false,
        isVoiceSearchProcessing: true,
        clearAiFailureMessage: true,
      ),
    );

    final recordingResult = await _stopVoiceSearchRecording();
    switch (recordingResult) {
      case Success<String?>(value: final filePath):
        final normalizedPath = filePath?.trim();
        if (normalizedPath == null || normalizedPath.isEmpty) {
          emit(state.copyWith(isVoiceSearchProcessing: false));
          return;
        }

        final transcriptResult = await _transcribeStationSearch(normalizedPath);
        switch (transcriptResult) {
          case Success<String>(value: final transcript):
            emit(state.copyWith(isVoiceSearchProcessing: false));
            await search(transcript);
          case Failure<String>(failure: final failure):
            emit(
              state.copyWith(
                isVoiceSearchProcessing: false,
                aiFailureMessage: failure.message,
              ),
            );
        }
      case Failure<String?>(failure: final failure):
        emit(
          state.copyWith(
            isVoiceSearchProcessing: false,
            aiFailureMessage: failure.message,
          ),
        );
    }
  }

  Future<_AiRankedStations> _rankStationsForCurrentContext({
    required List<Station> stations,
    required StationSearchQuery query,
  }) {
    final prompt =
        state.searchTerm.trim().isNotEmpty
            ? state.searchTerm.trim()
            : _recommendationPrompt(query);

    return _rankStationsForPrompt(prompt: prompt, stations: stations);
  }

  Future<_AiRankedStations> _rankStationsForPrompt({
    required String prompt,
    required List<Station> stations,
  }) async {
    if (!_rankStationsWithAi.isEnabled) {
      logOpenAiApi('AI ranking skipped: OPENAI_API_KEY was not provided.');
      return _AiRankedStations(stations: stations, hasAiResponse: false);
    }

    final candidates = _uniqueStations(
      stations,
    ).take(80).toList(growable: false);
    final result = await _rankStationsWithAi(
      prompt: prompt,
      candidateStations: candidates,
      favoriteStations: state.favoriteStations,
    );

    return switch (result) {
      Success<List<Station>>(value: final rankedStations) => _AiRankedStations(
        stations: [
          ...rankedStations,
          for (final station in stations)
            if (!rankedStations.any(
              (rankedStation) =>
                  rankedStation.stationUuid == station.stationUuid,
            ))
              station,
        ],
        hasAiResponse: rankedStations.isNotEmpty,
      ),
      Failure<List<Station>>(failure: final failure) => _AiRankedStations(
        stations: stations,
        hasAiResponse: false,
        failure: failure,
      ),
    };
  }

  List<Station> _uniqueStations(List<Station> stations) {
    final seenStationUuids = <String>{};
    return [
      for (final station in stations)
        if (seenStationUuids.add(station.stationUuid)) station,
    ];
  }

  String _recommendationPrompt(StationSearchQuery query) {
    final activeTags = <String>[
      if (query.tag != null) query.tag!,
      if (query.countryCode != null) query.countryCode!,
      if (query.language != null) query.language!,
    ];

    final filterContext =
        activeTags.isEmpty ? 'popular stations' : activeTags.join(', ');

    if (state.favoriteStations.isEmpty) {
      return 'Recommend the best station from these $filterContext.';
    }

    return 'Recommend stations similar to my favorites from these $filterContext.';
  }

  void _emitStationFailure(AppFailure failure) {
    emit(
      state.copyWith(
        status: DiscoverStatus.failure,
        aiRecommendationStatus: AiRecommendationStatus.unavailable,
        failureMessage: failure.message,
        failureKind:
            failure is NetworkFailure
                ? DiscoverFailureKind.network
                : DiscoverFailureKind.unknown,
      ),
    );
  }

  StationSearchQuery _queryForCurrentSelection({String? name, int? limit}) {
    final selectedQuery = state.activeFilter.query;
    return StationSearchQuery(
      name: name ?? (state.searchTerm.isEmpty ? null : state.searchTerm),
      tag: selectedQuery.tag,
      countryCode: selectedQuery.countryCode,
      language: selectedQuery.language,
      limit: limit ?? selectedQuery.limit,
      offset: selectedQuery.offset,
      hideBroken: selectedQuery.hideBroken,
      order: selectedQuery.order,
      reverse: selectedQuery.reverse,
    );
  }

  void _watchFavorites() {
    _favoritesSubscription ??= _watchFavoriteStations().listen((result) async {
      switch (result) {
        case Success<List<FavoriteStation>>(value: final favorites):
          if (!isClosed) {
            emit(state.copyWith(favoriteStations: favorites));
            await _rerankRecommendationAfterFavoritesChange();
          }
        case Failure<List<FavoriteStation>>():
      }
    });
  }

  Future<void> _rerankRecommendationAfterFavoritesChange() async {
    if (!_rankStationsWithAi.isEnabled ||
        state.stations.isEmpty ||
        state.searchTerm.isNotEmpty) {
      return;
    }

    final rankResult = await _rankStationsForPrompt(
      prompt: _recommendationPrompt(_queryForCurrentSelection(name: null)),
      stations: state.stations,
    );

    if (!isClosed) {
      emit(
        state.copyWith(
          stations: rankResult.stations,
          aiRecommendationStatus: _resolvedAiRecommendationStatus(rankResult),
          aiFailureMessage: rankResult.failure?.message,
          clearAiFailureMessage: rankResult.failure == null,
        ),
      );
    }
  }

  AiRecommendationStatus _pendingAiRecommendationStatus() {
    return _rankStationsWithAi.isEnabled
        ? AiRecommendationStatus.loading
        : AiRecommendationStatus.unavailable;
  }

  AiRecommendationStatus _resolvedAiRecommendationStatus(
    _AiRankedStations rankResult,
  ) {
    return rankResult.hasAiResponse
        ? AiRecommendationStatus.ready
        : AiRecommendationStatus.unavailable;
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
          volume: snapshot.volume,
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

class _AiRankedStations {
  const _AiRankedStations({
    required this.stations,
    required this.hasAiResponse,
    this.failure,
  });

  final List<Station> stations;
  final bool hasAiResponse;
  final AppFailure? failure;
}
