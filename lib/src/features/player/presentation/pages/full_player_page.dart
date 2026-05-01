import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../../discover/domain/entities/station.dart';
import '../../domain/entities/radio_playback_snapshot.dart';

class FullPlayerPage extends StatelessWidget {
  const FullPlayerPage({
    required this.station,
    required this.playbackStatus,
    required this.volume,
    required this.isFavorite,
    required this.similarStations,
    required this.artworkHeroTag,
    required this.onPlaybackToggle,
    required this.onFavoriteToggle,
    required this.onVolumeChanged,
    required this.onSeeAllSimilar,
    required this.onSimilarStationSelected,
    this.onPreviousStation,
    this.onNextStation,
    super.key,
  });

  final Station station;
  final RadioPlaybackStatus playbackStatus;
  final double volume;
  final bool isFavorite;
  final List<Station> similarStations;
  final Object artworkHeroTag;
  final VoidCallback onPlaybackToggle;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onSeeAllSimilar;
  final ValueChanged<Station> onSimilarStationSelected;
  final VoidCallback? onPreviousStation;
  final VoidCallback? onNextStation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleSimilarStations = similarStations
        .where((item) => item.stationUuid != station.stationUuid)
        .take(6)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            _PlayerHeader(onCollapse: () => Navigator.of(context).maybePop()),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final artworkSize =
                      (constraints.maxHeight * 0.28)
                          .clamp(156.0, 220.0)
                          .toDouble();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: [
                      Center(
                        child: _ParallaxArtwork(
                          station: station,
                          heroTag: artworkHeroTag,
                          isFavorite: isFavorite,
                          onFavoriteToggle: onFavoriteToggle,
                          size: artworkSize,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        station.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _locationLine(station),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _StationTags(station: station),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _streamLine(station),
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _VolumeControl(
                        volume: volume,
                        onChanged: onVolumeChanged,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _PlaybackControls(
                        playbackStatus: playbackStatus,
                        onPlaybackToggle: onPlaybackToggle,
                        onPreviousStation: onPreviousStation,
                        onNextStation: onNextStation,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _SimilarStations(
                        stations: visibleSimilarStations,
                        onSeeAll: onSeeAllSimilar,
                        onStationSelected: onSimilarStationSelected,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _locationLine(Station station) {
    return [station.countryCode, station.language]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(Localizable.metadataSeparator.text);
  }

  String _streamLine(Station station) {
    final pieces = [
      station.codec,
      if (station.bitrate != null && station.bitrate! > 0)
        Localizable.bitrateKbpsTemplate.format({'value': station.bitrate!}),
    ].whereType<String>().where((value) => value.isNotEmpty);

    return pieces.join(Localizable.metadataSeparator.text);
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.onCollapse});

  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.softLine)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              IconButton(
                tooltip: Localizable.collapsePlayer.text,
                onPressed: onCollapse,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
              Expanded(
                child: Text(
                  Localizable.nowPlayingTitle.text,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParallaxArtwork extends StatefulWidget {
  const _ParallaxArtwork({
    required this.station,
    required this.heroTag,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.size,
  });

  final Station station;
  final Object heroTag;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final double size;

  @override
  State<_ParallaxArtwork> createState() => _ParallaxArtworkState();
}

class _FavoriteArtworkButton extends StatelessWidget {
  const _FavoriteArtworkButton({
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isFavorite ? AppColors.brand : AppColors.surface,
      shape: const CircleBorder(),
      elevation: 8,
      shadowColor: AppColors.ink.withValues(alpha: 0.18),
      child: IconButton(
        tooltip:
            isFavorite
                ? Localizable.removeFavorite.text
                : Localizable.addFavorite.text,
        onPressed: onPressed,
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.surface : AppColors.brand,
        ),
      ),
    );
  }
}

class _ParallaxArtworkState extends State<_ParallaxArtwork> {
  StreamSubscription<GyroscopeEvent>? _subscription;
  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _subscription = gyroscopeEventStream(
      samplingPeriod: SensorInterval.uiInterval,
    ).listen((event) {
      if (!mounted) {
        return;
      }

      setState(() {
        _tiltX = (_tiltX + event.y * 2).clamp(-12.0, 12.0).toDouble();
        _tiltY = (_tiltY + event.x * 2).clamp(-12.0, 12.0).toDouble();
      });
    }, onError: (_) {});
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_tiltY * 0.008)
            ..rotateY(-_tiltX * 0.008)
            ..translate(_tiltX, _tiltY),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.22),
            offset: const Offset(0, 24),
            blurRadius: 36,
          ),
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.12),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          StationArtwork(
            imageUrl: widget.station.faviconUrl,
            size: widget.size,
            heroTag: widget.heroTag,
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _FavoriteArtworkButton(
              isFavorite: widget.isFavorite,
              onPressed: widget.onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationTags extends StatelessWidget {
  const _StationTags({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final tags = station.tags.take(3).toList(growable: false);
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children:
          tags.map((tag) {
            return Chip(
              label: Text(tag),
              visualDensity: VisualDensity.compact,
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.line),
            );
          }).toList(),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.playbackStatus,
    required this.onPlaybackToggle,
    required this.onPreviousStation,
    required this.onNextStation,
  });

  final RadioPlaybackStatus playbackStatus;
  final VoidCallback onPlaybackToggle;
  final VoidCallback? onPreviousStation;
  final VoidCallback? onNextStation;

  @override
  Widget build(BuildContext context) {
    final isBusy = playbackStatus == RadioPlaybackStatus.loading;
    final isPlaying = playbackStatus == RadioPlaybackStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: Localizable.previousStation.text,
          onPressed: isBusy ? null : onPreviousStation,
          icon: const Icon(Icons.skip_previous_rounded),
        ),
        const SizedBox(width: AppSpacing.xl),
        SizedBox.square(
          dimension: 76,
          child: FilledButton(
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            onPressed: isBusy ? null : onPlaybackToggle,
            child:
                isBusy
                    ? const SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                    : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 42,
                    ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        IconButton(
          tooltip: Localizable.nextStation.text,
          onPressed: isBusy ? null : onNextStation,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}

class _VolumeControl extends StatelessWidget {
  const _VolumeControl({required this.volume, required this.onChanged});

  final double volume;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizable.volume.text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        Row(
          children: [
            const Icon(Icons.volume_down_rounded, color: AppColors.ink),
            Expanded(
              child: Slider(
                value: volume.clamp(0.0, 1.0).toDouble(),
                onChanged: onChanged,
              ),
            ),
            const Icon(Icons.volume_up_rounded, color: AppColors.ink),
          ],
        ),
      ],
    );
  }
}

class _SimilarStations extends StatelessWidget {
  const _SimilarStations({
    required this.stations,
    required this.onSeeAll,
    required this.onStationSelected,
  });

  final List<Station> stations;
  final VoidCallback onSeeAll;
  final ValueChanged<Station> onStationSelected;

  @override
  Widget build(BuildContext context) {
    if (stations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      Localizable.similarStations.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.inkMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onSeeAll,
              child: Text(Localizable.seeAll.text),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 138,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stations.take(6).length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final station = stations[index];
              return _SimilarStationTile(
                station: station,
                onTap: () => onStationSelected(station),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarStationTile extends StatelessWidget {
  const _SimilarStationTile({required this.station, required this.onTap});

  final Station station;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: SizedBox(
          width: 104,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.ink.withValues(alpha: 0.08),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: StationArtwork(imageUrl: station.faviconUrl, size: 92),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                station.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
