import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_offline_state.dart';
import '../cubit/discover_cubit.dart';
import '../cubit/discover_state.dart';
import '../widgets/discover_filter_chips.dart';
import '../widgets/discover_header.dart';
import '../widgets/discover_loading_view.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/recommended_station_card.dart';
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
              current.playbackFailureMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.playbackFailureMessage ?? Localizable.playbackFailed.text,
            ),
          ),
        );
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brand,
                  onRefresh: context.read<DiscoverCubit>().refresh,
                  child: _DiscoverBody(state: state),
                ),
              ),
              if (state.hasMiniPlayer)
                MiniPlayerBar(
                  station: state.activeStation!,
                  playbackStatus: state.playbackStatus,
                  isFavorite: context.read<DiscoverCubit>().isFavorite(
                    state.activeStation!.stationUuid,
                  ),
                  onPlaybackToggle:
                      context.read<DiscoverCubit>().toggleMiniPlayerPlayback,
                  onFavoriteToggle:
                      () => context.read<DiscoverCubit>().toggleFavorite(
                        state.activeStation!,
                      ),
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

        final similarStations = state.stations
            .where((item) => item.stationUuid != station.stationUuid)
            .take(6)
            .toList(growable: false);

        return FullPlayerPage(
          station: station,
          playbackStatus: state.playbackStatus,
          volume: state.volume,
          isFavorite: context.read<DiscoverCubit>().isFavorite(
            station.stationUuid,
          ),
          similarStations: similarStations,
          artworkHeroTag: _discoverArtworkHeroTag,
          onPlaybackToggle:
              context.read<DiscoverCubit>().toggleMiniPlayerPlayback,
          onStop: () async {
            await context.read<DiscoverCubit>().stopPlayback();
          },
          onFavoriteToggle:
              () => context.read<DiscoverCubit>().toggleFavorite(station),
          onVolumeChanged:
              (volume) => context.read<DiscoverCubit>().setVolume(volume),
        );
      },
    );
  }
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
          ),
          SizedBox(
            height: 420,
            child: AppEmptyState(
              title: Localizable.noStationsFoundTitle.text,
              message:
                  state.searchTerm.isEmpty
                      ? Localizable.noStationsForFilterMessage.text
                      : Localizable.noStationsForSearchMessage.text,
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
        ),
        const SizedBox(height: AppSpacing.lg),
        if (state.recommendedStation != null) ...[
          RecommendedStationCard(
            station: state.recommendedStation!,
            isFavorite: context.read<DiscoverCubit>().isFavorite(
              state.recommendedStation!.stationUuid,
            ),
            isLoading:
                state.isPlaybackLoading &&
                state.activeStation?.stationUuid ==
                    state.recommendedStation!.stationUuid,
            onPlay:
                () => context.read<DiscoverCubit>().playStation(
                  state.recommendedStation!,
                ),
            onFavoriteToggle:
                () => context.read<DiscoverCubit>().toggleFavorite(
                  state.recommendedStation!,
                ),
          ),
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
