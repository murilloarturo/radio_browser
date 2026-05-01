import 'dart:async';
import 'dart:math' as math;

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
    required this.onStop,
    required this.onFavoriteToggle,
    required this.onVolumeChanged,
    super.key,
  });

  final Station station;
  final RadioPlaybackStatus playbackStatus;
  final double volume;
  final bool isFavorite;
  final List<Station> similarStations;
  final Object artworkHeroTag;
  final VoidCallback onPlaybackToggle;
  final VoidCallback onStop;
  final VoidCallback onFavoriteToggle;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          children: [
            _PlayerHeader(onClose: () => Navigator.of(context).maybePop()),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: _ParallaxArtwork(
                station: station,
                heroTag: artworkHeroTag,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              station.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(
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
              style: textTheme.titleMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            _StationTags(station: station),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _streamLine(station),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.xl),
            AnimatedAudioWaveform(
              isActive: playbackStatus == RadioPlaybackStatus.playing,
            ),
            const SizedBox(height: AppSpacing.xl),
            _PlaybackControls(
              playbackStatus: playbackStatus,
              onPlaybackToggle: onPlaybackToggle,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ActionButtons(
              isFavorite: isFavorite,
              onStop: onStop,
              onFavoriteToggle: onFavoriteToggle,
            ),
            const SizedBox(height: AppSpacing.xl),
            _VolumeControl(volume: volume, onChanged: onVolumeChanged),
            const SizedBox(height: AppSpacing.xl),
            _SimilarStations(stations: similarStations),
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
  const _PlayerHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: Localizable.collapsePlayer.text,
          onPressed: onClose,
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
        IconButton(
          tooltip: Localizable.playerOptions.text,
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }
}

class _ParallaxArtwork extends StatefulWidget {
  const _ParallaxArtwork({required this.station, required this.heroTag});

  final Station station;
  final Object heroTag;

  @override
  State<_ParallaxArtwork> createState() => _ParallaxArtworkState();
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
      child: StationArtwork(
        imageUrl: widget.station.faviconUrl,
        size: 220,
        heroTag: widget.heroTag,
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

class AnimatedAudioWaveform extends StatefulWidget {
  const AnimatedAudioWaveform({required this.isActive, super.key});

  final bool isActive;

  @override
  State<AnimatedAudioWaveform> createState() => _AnimatedAudioWaveformState();
}

class _AnimatedAudioWaveformState extends State<AnimatedAudioWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimatedAudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation() {
    if (widget.isActive) {
      _controller.repeat();
      return;
    }

    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _WaveformPainter(progress: _controller.value),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const barCount = 72;
    final centerY = size.height / 2;
    final gap = size.width / barCount;
    final darkPaint =
        Paint()
          ..color = AppColors.ink
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
    final lightPaint =
        Paint()
          ..color = AppColors.line
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    for (var index = 0; index < barCount; index++) {
      final x = index * gap + gap / 2;
      final wave = math.sin(index * 0.42 + progress * math.pi * 2);
      final accent = math.sin(index * 0.17 + progress * math.pi * 4);
      final height = 10 + (wave.abs() * 26) + (accent.abs() * 10);
      final paint =
          index < barCount * (0.42 + progress * 0.16) ? darkPaint : lightPaint;

      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.playbackStatus,
    required this.onPlaybackToggle,
  });

  final RadioPlaybackStatus playbackStatus;
  final VoidCallback onPlaybackToggle;

  @override
  Widget build(BuildContext context) {
    final isBusy = playbackStatus == RadioPlaybackStatus.loading;
    final isPlaying = playbackStatus == RadioPlaybackStatus.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: Localizable.previousStation.text,
          onPressed: null,
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
          onPressed: null,
          icon: const Icon(Icons.skip_next_rounded),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isFavorite,
    required this.onStop,
    required this.onFavoriteToggle,
  });

  final bool isFavorite;
  final VoidCallback onStop;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onStop,
            icon: const Icon(Icons.stop_rounded),
            label: Text(Localizable.stop.text),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onFavoriteToggle,
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            label: Text(Localizable.favorite.text),
          ),
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
  const _SimilarStations({required this.stations});

  final List<Station> stations;

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
              child: Text(
                Localizable.similarStations.text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: () {}, child: Text(Localizable.seeAll.text)),
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
              return _SimilarStationTile(station: stations[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _SimilarStationTile extends StatelessWidget {
  const _SimilarStationTile({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}
