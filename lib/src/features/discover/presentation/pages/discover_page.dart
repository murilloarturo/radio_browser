import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_offline_state.dart';
import '../../../../core/widgets/persistent_error_snack_bar.dart';
import '../../domain/entities/station.dart';
import '../cubit/discover_cubit.dart';
import '../cubit/discover_state.dart';
import '../widgets/ai_recommendation_empty_card.dart';
import '../widgets/discover_filter_chips.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_loading_view.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/recommended_stations_rail.dart';
import '../widgets/station_list.dart';
import '../widgets/station_search_bar.dart';
import '../../../player/presentation/pages/full_player_page.dart';
import '../../../player/presentation/pages/full_player_route.dart';

const _discoverArtworkHeroTag = 'discover-player-artwork';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscoverCubit, DiscoverState>(
      listenWhen:
          (previous, current) =>
              previous.playbackFailureMessage !=
                      current.playbackFailureMessage &&
                  current.playbackFailureMessage != null ||
              previous.aiFailureMessage != current.aiFailureMessage &&
                  current.aiFailureMessage != null,
      listener: (context, state) {
        final message =
            state.playbackFailureMessage ??
            state.aiFailureMessage ??
            Localizable.playbackFailed.text;
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        messenger.showSnackBar(
          persistentErrorSnackBar(
            context: context,
            message: message,
            closeTooltip: Localizable.dismissMessage.text,
          ),
        );
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: context.appPalette.brand,
                  onRefresh: context.read<DiscoverCubit>().refresh,
                  child: _DiscoverBody(state: state),
                ),
              ),
              if (state.hasMiniPlayer)
                MiniPlayerBar(
                  station: state.activeStation!,
                  playbackStatus: state.playbackStatus,
                  onPlaybackToggle:
                      context.read<DiscoverCubit>().toggleMiniPlayerPlayback,
                  onOpenPlayer: () => _openDiscoverPlayer(context),
                  artworkHeroTag: _discoverArtworkHeroTag,
                ),
            ],
          ),
        );
      },
    );
  }
}

void _openDiscoverPlayer(BuildContext context) {
  final cubit = context.read<DiscoverCubit>();
  Navigator.of(context).push(
    buildFullPlayerRoute(
      child: BlocProvider.value(
        value: cubit,
        child: const _DiscoverFullPlayerPage(),
      ),
    ),
  );
}

class _DiscoverFullPlayerPage extends StatelessWidget {
  const _DiscoverFullPlayerPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        final station = state.activeStation;
        if (station == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).maybePop();
            }
          });
          return const SizedBox.shrink();
        }

        final stationCycle = _uniqueStations(state.stations);
        final similarStations = stationCycle
            .where((item) => item.stationUuid != station.stationUuid)
            .take(6)
            .toList(growable: false);
        final previousStation = _adjacentStation(
          activeStation: station,
          stations: stationCycle,
          step: -1,
        );
        final nextStation = _adjacentStation(
          activeStation: station,
          stations: stationCycle,
          step: 1,
        );
        final cubit = context.read<DiscoverCubit>();

        return FullPlayerPage(
          station: station,
          playbackStatus: state.playbackStatus,
          volume: state.volume,
          isFavorite: cubit.isFavorite(station.stationUuid),
          similarStations: similarStations,
          artworkHeroTag: _discoverArtworkHeroTag,
          onPlaybackToggle: cubit.toggleMiniPlayerPlayback,
          onFavoriteToggle: () => cubit.toggleFavorite(station),
          onVolumeChanged: cubit.setVolume,
          onSeeAllSimilar: () => Navigator.of(context).maybePop(),
          onSimilarStationSelected: cubit.playStation,
          onPreviousStation:
              previousStation == null
                  ? null
                  : () => cubit.playStation(previousStation),
          onNextStation:
              nextStation == null ? null : () => cubit.playStation(nextStation),
        );
      },
    );
  }
}

List<Station> _uniqueStations(List<Station> stations) {
  final seenStationUuids = <String>{};
  return [
    for (final station in stations)
      if (seenStationUuids.add(station.stationUuid)) station,
  ];
}

Station? _adjacentStation({
  required Station activeStation,
  required List<Station> stations,
  required int step,
}) {
  if (stations.length < 2) {
    return null;
  }

  final activeIndex = stations.indexWhere(
    (station) => station.stationUuid == activeStation.stationUuid,
  );
  if (activeIndex == -1) {
    return step > 0
        ? stations.firstWhere(
          (station) => station.stationUuid != activeStation.stationUuid,
        )
        : stations.lastWhere(
          (station) => station.stationUuid != activeStation.stationUuid,
        );
  }

  var nextIndex = activeIndex;
  for (var attempt = 0; attempt < stations.length - 1; attempt++) {
    nextIndex = (nextIndex + step) % stations.length;
    if (nextIndex < 0) {
      nextIndex += stations.length;
    }

    final nextStation = stations[nextIndex];
    if (nextStation.stationUuid != activeStation.stationUuid) {
      return nextStation;
    }
  }

  return null;
}

class _DiscoverBody extends StatelessWidget {
  const _DiscoverBody({required this.state});

  final DiscoverState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasStations) {
      return const DiscoverLoadingView();
    }

    if (state.status == DiscoverStatus.failure && !state.hasStations) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const DiscoverHeader(),
          const SizedBox(height: AppSpacing.lg),
          StationSearchBar(
            value: state.searchTerm,
            onSubmitted: context.read<DiscoverCubit>().search,
            onVoicePressed: context.read<DiscoverCubit>().toggleVoiceSearch,
            isVoiceSearchRecording: state.isVoiceSearchRecording,
            isVoiceSearchProcessing: state.isVoiceSearchProcessing,
          ),
          SizedBox(
            height: 520,
            child:
                state.isNetworkFailure
                    ? AppOfflineState(
                      onRetry: context.read<DiscoverCubit>().refresh,
                    )
                    : AppErrorState(
                      message:
                          state.failureMessage ??
                          Localizable.pleaseTryAgainMessage.text,
                      onRetry: context.read<DiscoverCubit>().refresh,
                    ),
          ),
        ],
      );
    }

    if (state.status == DiscoverStatus.success && !state.hasStations) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const DiscoverHeader(),
          const SizedBox(height: AppSpacing.lg),
          StationSearchBar(
            value: state.searchTerm,
            onSubmitted: context.read<DiscoverCubit>().search,
            onVoicePressed: context.read<DiscoverCubit>().toggleVoiceSearch,
            isVoiceSearchRecording: state.isVoiceSearchRecording,
            isVoiceSearchProcessing: state.isVoiceSearchProcessing,
          ),
          SizedBox(
            height: 420,
            child: AppEmptyState(
              title: Localizable.noStationsFoundTitle.text,
              message:
                  state.searchTerm.isEmpty
                      ? Localizable.noStationsForFilterMessage.text
                      : Localizable.noStationsForSearchMessage.text,
              assetPath: AppAssets.noResultsIllustration,
              assetSemanticLabel: Localizable.noStationsFoundTitle.text,
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        const DiscoverHeader(),
        const SizedBox(height: AppSpacing.lg),
        StationSearchBar(
          value: state.searchTerm,
          onSubmitted: context.read<DiscoverCubit>().search,
          onVoicePressed: context.read<DiscoverCubit>().toggleVoiceSearch,
          isVoiceSearchRecording: state.isVoiceSearchRecording,
          isVoiceSearchProcessing: state.isVoiceSearchProcessing,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.hasAiRecommendation) ...[
          RecommendedStationsRail(
            stations: state.recommendedStations,
            favoriteStationUuids: state.favoriteStationUuids,
            activeStationUuid: state.activeStation?.stationUuid,
            isPlaybackLoading: state.isPlaybackLoading,
            onPlay: context.read<DiscoverCubit>().playStation,
            onFavoriteToggle: context.read<DiscoverCubit>().toggleFavorite,
          ),
          const SizedBox(height: AppSpacing.lg),
        ] else ...[
          AiRecommendationEmptyCard(isLoading: state.isAiRecommendationLoading),
          const SizedBox(height: AppSpacing.lg),
        ],
        DiscoverFilterChips(
          activeFilter: state.activeFilter,
          onFilterSelected: context.read<DiscoverCubit>().selectFilter,
        ),
        if (state.isLoading) ...[
          const SizedBox(height: AppSpacing.md),
          const LinearProgressIndicator(minHeight: 2),
        ],
        const SizedBox(height: AppSpacing.md),
        StationList(
          stations: state.stations,
          favoriteStationUuids: state.favoriteStationUuids,
          activeStationUuid: state.activeStation?.stationUuid,
          isPlaybackLoading: state.isPlaybackLoading,
          onPlay: context.read<DiscoverCubit>().playStation,
          onFavoriteToggle: context.read<DiscoverCubit>().toggleFavorite,
        ),
      ],
    );
  }
}
