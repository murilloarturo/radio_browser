import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/station.dart';
import 'station_list_item.dart';

class StationList extends StatelessWidget {
  const StationList({
    required this.stations,
    required this.favoriteStationUuids,
    required this.onPlay,
    required this.onFavoriteToggle,
    super.key,
  });

  final List<Station> stations;
  final Set<String> favoriteStationUuids;
  final ValueChanged<Station> onPlay;
  final ValueChanged<Station> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          for (final indexedStation in stations.indexed) ...[
            StationListItem(
              station: indexedStation.$2,
              isFavorite: favoriteStationUuids.contains(
                indexedStation.$2.stationUuid,
              ),
              onPlay: () => onPlay(indexedStation.$2),
              onFavoriteToggle: () => onFavoriteToggle(indexedStation.$2),
            ),
            if (indexedStation.$1 != stations.length - 1)
              const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}
