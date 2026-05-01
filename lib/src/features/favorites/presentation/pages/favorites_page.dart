import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_block.dart';
import '../../../../core/widgets/persistent_error_snack_bar.dart';
import '../../../discover/presentation/widgets/mini_player_bar.dart';
import '../../../discover/presentation/widgets/recommended_station_card.dart';
import '../../../player/presentation/pages/full_player_page.dart';
import '../../../player/presentation/pages/full_player_route.dart';
import '../../domain/entities/favorite_station.dart';
import '../cubit/favorites_cubit.dart';
import '../cubit/favorites_state.dart';
import '../mappers/favorite_station_mapper.dart';

const _favoritesArtworkHeroTag = 'favorites-player-artwork';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({required this.onDiscoverRequested, super.key});

  final VoidCallback onDiscoverRequested;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesCubit, FavoritesState>(
      listenWhen:
          (previous, current) =>
              previous.playbackFailureMessage !=
                  current.playbackFailureMessage &&
              current.playbackFailureMessage != null,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
        messenger.showSnackBar(
          persistentErrorSnackBar(
            context: context,
            message:
                state.playbackFailureMessage ?? Localizable.playbackFailed.text,
            closeTooltip: Localizable.dismissMessage.text,
          ),
        );
      },
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              Expanded(child: _FavoritesBody(state: state)),
              if (state.hasMiniPlayer)
                MiniPlayerBar(
                  station: state.activeStation!,
                  playbackStatus: state.playbackStatus,
                  onPlaybackToggle:
                      context.read<FavoritesCubit>().toggleMiniPlayerPlayback,
                  onOpenPlayer:
                      () => _openFavoritesPlayer(
                        context,
                        onDiscoverRequested: onDiscoverRequested,
                      ),
                  artworkHeroTag: _favoritesArtworkHeroTag,
                ),
            ],
          ),
        );
      },
    );
  }
}

void _openFavoritesPlayer(
  BuildContext context, {
  required VoidCallback onDiscoverRequested,
}) {
  final cubit = context.read<FavoritesCubit>();
  Navigator.of(context).push(
    buildFullPlayerRoute(
      child: BlocProvider.value(
        value: cubit,
        child: _FavoritesFullPlayerPage(
          onDiscoverRequested: onDiscoverRequested,
        ),
      ),
    ),
  );
}

class _FavoritesFullPlayerPage extends StatelessWidget {
  const _FavoritesFullPlayerPage({required this.onDiscoverRequested});

  final VoidCallback onDiscoverRequested;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
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

        final favoriteStation = _findActiveFavorite(state);
        final similarStations = state.similarStations
            .where((item) => item.stationUuid != station.stationUuid)
            .take(6)
            .toList(growable: false);
        final previousStation =
            similarStations.isEmpty ? null : similarStations.last;
        final nextStation =
            similarStations.isEmpty ? null : similarStations.first;
        final cubit = context.read<FavoritesCubit>();

        return FullPlayerPage(
          station: station,
          playbackStatus: state.playbackStatus,
          volume: state.volume,
          isFavorite: favoriteStation != null,
          similarStations: similarStations,
          artworkHeroTag: _favoritesArtworkHeroTag,
          onPlaybackToggle: cubit.toggleMiniPlayerPlayback,
          onFavoriteToggle: () {
            if (favoriteStation != null) {
              cubit.removeFavorite(favoriteStation);
              return;
            }
            cubit.toggleFavorite(station);
          },
          onVolumeChanged: cubit.setVolume,
          onSeeAllSimilar: () {
            Navigator.of(context).maybePop();
            onDiscoverRequested();
          },
          onSimilarStationSelected: cubit.playSimilarStation,
          onPreviousStation:
              previousStation == null
                  ? null
                  : () => cubit.playSimilarStation(previousStation),
          onNextStation:
              nextStation == null
                  ? null
                  : () => cubit.playSimilarStation(nextStation),
        );
      },
    );
  }
}

FavoriteStation? _findActiveFavorite(FavoritesState state) {
  for (final station in state.stations) {
    if (station.stationUuid == state.activeStation?.stationUuid) {
      return station;
    }
  }

  return null;
}

class _FavoritesBody extends StatelessWidget {
  const _FavoritesBody({required this.state});

  final FavoritesState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && !state.hasStations) {
      return const _FavoritesLoadingView();
    }

    if (state.status == FavoritesStatus.failure && !state.hasStations) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _FavoritesHeader(),
          SizedBox(
            height: 420,
            child: AppErrorState(
              message:
                  state.failureMessage ??
                  Localizable.pleaseTryAgainMessage.text,
              onRetry: context.read<FavoritesCubit>().load,
            ),
          ),
        ],
      );
    }

    if (!state.hasStations) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const _FavoritesHeader(),
          SizedBox(
            height: 420,
            child: AppEmptyState(
              title: Localizable.noFavoritesTitle.text,
              message: Localizable.noFavoritesMessage.text,
              assetPath: AppAssets.favoritesEmptyIllustration,
              assetSemanticLabel: Localizable.noFavoritesTitle.text,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: state.stations.length + 1,
      separatorBuilder: (_, index) {
        return index == 0
            ? const SizedBox(height: AppSpacing.lg)
            : const SizedBox(height: AppSpacing.md);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _FavoritesHeader();
        }

        final favoriteStation = state.stations[index - 1];
        final station = favoriteStation.toStation();

        return RecommendedStationCard(
          title: null,
          station: station,
          isFavorite: true,
          isLoading:
              state.isPlaybackLoading &&
              state.activeStation?.stationUuid == station.stationUuid,
          onPlay:
              () => context.read<FavoritesCubit>().playStation(favoriteStation),
          onFavoriteToggle:
              () => context.read<FavoritesCubit>().removeFavorite(
                favoriteStation,
              ),
        );
      },
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      Localizable.favoritesTitle.text,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FavoritesLoadingView extends StatelessWidget {
  const _FavoritesLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        _FavoritesHeader(),
        SizedBox(height: AppSpacing.lg),
        AppLoadingBlock(height: 148),
        SizedBox(height: AppSpacing.md),
        AppLoadingBlock(height: 148),
      ],
    );
  }
}
