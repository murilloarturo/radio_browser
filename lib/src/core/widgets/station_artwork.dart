import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';

class StationArtwork extends StatelessWidget {
  const StationArtwork({
    this.imageUrl,
    this.size = 70,
    this.heroTag,
    super.key,
  });

  final String? imageUrl;
  final double size;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadii.xs);
    final colors = context.appPalette;

    final artwork = ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.artworkBase,
          border: Border.all(color: colors.line),
          borderRadius: borderRadius,
        ),
        child: SizedBox.square(
          dimension: size,
          child:
              imageUrl == null
                  ? const _StationArtworkPlaceholder()
                  : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, _, _) => const _StationArtworkPlaceholder(),
                  ),
        ),
      ),
    );

    if (heroTag == null) {
      return artwork;
    }

    return Hero(tag: heroTag!, child: artwork);
  }
}

class _StationArtworkPlaceholder extends StatelessWidget {
  const _StationArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return Icon(Icons.image_outlined, color: colors.artworkGlyph, size: 32);
  }
}
