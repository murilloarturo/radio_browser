import 'package:flutter/material.dart';

import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/station.dart';
import 'station_list_item.dart';

class StationList extends StatelessWidget {
  const StationList({
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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.line),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        children: [
          for (final indexedStation in stations.indexed) ...[
            StationListItem(
              station: indexedStation.$2,
              isFavorite: favoriteStationUuids.contains(
                indexedStation.$2.stationUuid,
              ),
              isLoading:
                  isPlaybackLoading &&
                  activeStationUuid == indexedStation.$2.stationUuid,
              onPlay: () => onPlay(indexedStation.$2),
              onFavoriteToggle: () => onFavoriteToggle(indexedStation.$2),
            ),
            if (indexedStation.$1 != stations.length - 1)
              Divider(height: 1, color: colors.line),
          ],
        ],
      ),
    );
  }
}
