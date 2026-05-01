import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../../player/domain/entities/radio_playback_snapshot.dart';
import '../../domain/entities/station.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    required this.station,
    required this.playbackStatus,
    required this.onPlaybackToggle,
    required this.onOpenPlayer,
    required this.artworkHeroTag,
    super.key,
  });

  final Station station;
  final RadioPlaybackStatus playbackStatus;
  final VoidCallback onPlaybackToggle;
  final VoidCallback onOpenPlayer;
  final Object artworkHeroTag;

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.vertical(
      top: Radius.circular(AppRadii.lg),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.16),
              offset: const Offset(0, -8),
              blurRadius: 24,
            ),
            BoxShadow(
              color: AppColors.ink.withValues(alpha: 0.10),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Material(
          color: AppColors.surface,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onOpenPlayer,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  StationArtwork(
                    imageUrl: station.faviconUrl,
                    size: 52,
                    heroTag: artworkHeroTag,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          station.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _stationSubtitle(station),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: _playbackTooltip,
                    onPressed:
                        playbackStatus == RadioPlaybackStatus.loading
                            ? null
                            : onPlaybackToggle,
                    icon:
                        playbackStatus == RadioPlaybackStatus.loading
                            ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(
                              playbackStatus == RadioPlaybackStatus.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.ink,
                              size: 32,
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _playbackTooltip {
    return playbackStatus == RadioPlaybackStatus.playing
        ? Localizable.pauseStation.text
        : Localizable.resumeStation.text;
  }

  String _stationSubtitle(Station station) {
    final pieces = [
      station.countryCode,
      if (station.tags.isNotEmpty)
        station.tags.take(3).join(Localizable.listSeparator.text),
    ].whereType<String>().where((value) => value.isNotEmpty);

    return pieces.join(Localizable.metadataSeparator.text);
  }
}
