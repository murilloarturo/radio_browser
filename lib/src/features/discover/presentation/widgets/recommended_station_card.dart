import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../../../core/widgets/station_artwork.dart';
import '../../domain/entities/station.dart';
import 'favorite_pill_button.dart';
import 'play_station_button.dart';

class RecommendedStationCard extends StatelessWidget {
  const RecommendedStationCard({
    required this.station,
    required this.isFavorite,
    required this.isLoading,
    required this.onPlay,
    required this.onFavoriteToggle,
    this.title = Localizable.recommendedForYou,
    super.key,
  });

  final Station station;
  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onPlay;
  final VoidCallback onFavoriteToggle;
  final Localizable? title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.appPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!.text,
            style: textTheme.titleMedium?.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.line),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.08),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
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
                                color: colors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _metadataLine(station),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _recommendationText(station),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colors.ink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FavoritePillButton(
                              isFavorite: isFavorite,
                              onPressed: onFavoriteToggle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          PlayStationButton(
                            label: Localizable.play,
                            isLoading: isLoading,
                            onPressed: onPlay,
                          ),
                        ],
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
