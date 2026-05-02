import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../../domain/entities/station.dart';
import 'recommended_station_card.dart';

class RecommendedStationsRail extends StatefulWidget {
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
  State<RecommendedStationsRail> createState() =>
      _RecommendedStationsRailState();
}

class _RecommendedStationsRailState extends State<RecommendedStationsRail> {
  static const double _itemHeight = 172;
  int _activeIndex = 0;

  @override
  void didUpdateWidget(covariant RecommendedStationsRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeIndex >= widget.stations.length) {
      _activeIndex = widget.stations.isEmpty ? 0 : widget.stations.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final cardWidth = MediaQuery.sizeOf(context).width - AppSpacing.lg * 2;
    final activeIndex =
        widget.stations.isEmpty
            ? 0
            : _activeIndex.clamp(0, widget.stations.length - 1);

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
          height: _itemHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              _syncActiveIndex(notification.metrics.pixels, cardWidth);
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: widget.stations.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                final station = widget.stations[index];
                return SizedBox(
                  width: cardWidth,
                  child: RecommendedStationCard(
                    title: null,
                    station: station,
                    isFavorite: widget.favoriteStationUuids.contains(
                      station.stationUuid,
                    ),
                    isLoading:
                        widget.isPlaybackLoading &&
                        widget.activeStationUuid == station.stationUuid,
                    onPlay: () => widget.onPlay(station),
                    onFavoriteToggle: () => widget.onFavoriteToggle(station),
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.stations.length > 1) ...[
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: _RecommendationStepper(
              itemCount: widget.stations.length,
              activeIndex: activeIndex,
            ),
          ),
        ],
      ],
    );
  }

  void _syncActiveIndex(double pixels, double cardWidth) {
    if (widget.stations.length <= 1) {
      return;
    }

    final pageExtent = cardWidth + AppSpacing.md;
    final nextIndex = (pixels / pageExtent).round().clamp(
      0,
      widget.stations.length - 1,
    );

    if (nextIndex != _activeIndex) {
      setState(() => _activeIndex = nextIndex);
    }
  }
}

class _RecommendationStepper extends StatelessWidget {
  const _RecommendationStepper({
    required this.itemCount,
    required this.activeIndex,
  });

  final int itemCount;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < itemCount; index++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: index == activeIndex ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color:
                  index == activeIndex
                      ? colors.brand
                      : colors.line.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppRadii.xs),
            ),
          ),
          if (index != itemCount - 1) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}
