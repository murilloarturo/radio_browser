import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_block.dart';
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
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesCubit, FavoritesState>(
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
              Expanded(child: _FavoritesBody(state: state)),
              if (state.hasMiniPlayer)
                MiniPlayerBar(
                  station: state.activeStation!,
                  playbackStatus: state.playbackStatus,
                  isFavorite: _findActiveFavorite(state) != null,
                  onPlaybackToggle:
                      context.read<FavoritesCubit>().toggleMiniPlayerPlayback,
                  onFavoriteToggle: () {
                    final favoriteStation = _findActiveFavorite(state);
                    if (favoriteStation != null) {
                      context.read<FavoritesCubit>().removeFavorite(
                        favoriteStation,
                      );
                      return;
                    }
                    context.read<FavoritesCubit>().toggleFavorite(
                      state.activeStation!,
                    );
                  },
                  onOpenPlayer: () => _openFavoritesPlayer(context),
                  artworkHeroTag: _favoritesArtworkHeroTag,
                ),
            ],
          ),
        );
      },
    );
  }
}

void _openFavoritesPlayer(BuildContext context) {
  final cubit = context.read<FavoritesCubit>();
  Navigator.of(context).push(
    buildFullPlayerRoute(
      child: BlocProvider.value(
        value: cubit,
        child: const _FavoritesFullPlayerPage(),
      ),
    ),
  );
}

class _FavoritesFullPlayerPage extends StatelessWidget {
  const _FavoritesFullPlayerPage();

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
        final similarStations = state.stations
            .map((item) => item.toStation())
            .where((item) => item.stationUuid != station.stationUuid)
            .take(6)
            .toList(growable: false);

        return FullPlayerPage(
          station: station,
          playbackStatus: state.playbackStatus,
          volume: state.volume,
          isFavorite: favoriteStation != null,
          similarStations: similarStations,
          artworkHeroTag: _favoritesArtworkHeroTag,
          onPlaybackToggle:
              context.read<FavoritesCubit>().toggleMiniPlayerPlayback,
          onStop: () async {
            await context.read<FavoritesCubit>().stopPlayback();
          },
          onFavoriteToggle: () {
            if (favoriteStation != null) {
              context.read<FavoritesCubit>().removeFavorite(favoriteStation);
              return;
            }
            context.read<FavoritesCubit>().toggleFavorite(station);
          },
          onVolumeChanged:
              (volume) => context.read<FavoritesCubit>().setVolume(volume),
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
