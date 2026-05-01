import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../domain/entities/station.dart';
import 'favorite_icon_button.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    required this.station,
    required this.isPlaying,
    required this.isFavorite,
    required this.onPlaybackToggle,
    required this.onFavoriteToggle,
    super.key,
  });

  final Station station;
  final bool isPlaying;
  final bool isFavorite;
  final VoidCallback onPlaybackToggle;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.sm,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            StationArtwork(imageUrl: station.faviconUrl, size: 52),
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
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _stationSubtitle(station),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: isPlaying ? 'Pause preview' : 'Resume preview',
              onPressed: onPlaybackToggle,
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.ink,
                size: 32,
              ),
            ),
            FavoriteIconButton(
              isFavorite: isFavorite,
              onPressed: onFavoriteToggle,
            ),
          ],
        ),
      ),
    );
  }

  String _stationSubtitle(Station station) {
    final pieces = [
      station.countryCode,
      if (station.tags.isNotEmpty) station.tags.take(3).join(', '),
    ].whereType<String>().where((value) => value.isNotEmpty);

    return pieces.join(' - ');
  }
}
