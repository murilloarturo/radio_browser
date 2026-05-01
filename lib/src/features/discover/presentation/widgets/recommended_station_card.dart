import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../domain/entities/station.dart';
import 'favorite_icon_button.dart';
import 'play_station_button.dart';

class RecommendedStationCard extends StatelessWidget {
  const RecommendedStationCard({
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizable.recommendedForYou.text,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                StationArtwork(imageUrl: station.faviconUrl, size: 104),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          FavoriteIconButton(
                            isFavorite: isFavorite,
                            onPressed: onFavoriteToggle,
                          ),
                        ],
                      ),
                      Text(
                        _metadataLine(station),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _recommendationText(station),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.ink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PlayStationButton(
                          label: Localizable.play,
                          isLoading: isLoading,
                          onPressed: onPlay,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _metadataLine(Station station) {
    return [
          station.countryCode,
          if (station.tags.isNotEmpty) station.tags.first,
        ]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(Localizable.metadataSeparator.text);
  }

  String _recommendationText(Station station) {
    final tag =
        station.tags.isEmpty
            ? Localizable.listeningFallback.text
            : station.tags.first;
    return Localizable.recommendationTemplate.format({'value': tag});
  }
}
