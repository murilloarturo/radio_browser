import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../domain/entities/station.dart';
import 'favorite_icon_button.dart';
import 'play_station_button.dart';

class StationListItem extends StatelessWidget {
  const StationListItem({
    required this.station,
    required this.isFavorite,
    required this.isLoading,
    required this.onPlay,
    required this.onFavoriteToggle,
    super.key,
  });

  final Station station;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          StationArtwork(imageUrl: station.faviconUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationLine(station),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  _tagsLine(station),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                Text(
                  _streamLine(station),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FavoriteIconButton(
                isFavorite: isFavorite,
                onPressed: onFavoriteToggle,
              ),
              PlayStationButton(isLoading: isLoading, onPressed: onPlay),
            ],
          ),
        ],
      ),
    );
  }

  String _locationLine(Station station) {
    return [station.countryCode, station.language]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(Localizable.metadataSeparator.text);
  }

  String _tagsLine(Station station) {
    if (station.tags.isEmpty) {
      return Localizable.untaggedStation.text;
    }

    return station.tags.take(3).join(Localizable.listSeparator.text);
  }

  String _streamLine(Station station) {
    final parts =
        [
          station.codec,
          if (station.bitrate != null && station.bitrate! > 0)
            Localizable.bitrateKbpsTemplate.format({'value': station.bitrate!}),
        ].whereType<String>();

    return parts.join(Localizable.metadataSeparator.text);
  }
}
