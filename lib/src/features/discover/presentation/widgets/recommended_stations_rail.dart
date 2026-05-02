import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../domain/entities/station.dart';
import 'recommended_station_card.dart';

class RecommendedStationsRail extends StatelessWidget {
  const RecommendedStationsRail({
    required this.stations,
    required this.favoriteStationUuids,
    required this.activeStationUuid,
    required this.isPlaybackLoading,
    required this.onPlay,
    required this.onFavoriteToggle,
    super.key,
  });

  final List<Station> stations;
  final Set<String> favoriteStationUuids;
  final String? activeStationUuid;
  final bool isPlaybackLoading;
  final ValueChanged<Station> onPlay;
  final ValueChanged<Station> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final cardWidth = MediaQuery.sizeOf(context).width - AppSpacing.lg * 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizable.recommendedForYou.text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: stations.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final station = stations[index];
              return SizedBox(
                width: cardWidth,
                child: RecommendedStationCard(
                  title: null,
                  station: station,
                  isFavorite: favoriteStationUuids.contains(
                    station.stationUuid,
                  ),
                  isLoading:
                      isPlaybackLoading &&
                      activeStationUuid == station.stationUuid,
                  onPlay: () => onPlay(station),
                  onFavoriteToggle: () => onFavoriteToggle(station),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
