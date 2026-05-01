import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';

class StationArtwork extends StatelessWidget {
  const StationArtwork({this.imageUrl, this.size = 70, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppRadii.xs);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.artworkBase,
          border: Border.all(color: AppColors.line),
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
  }
}

class _StationArtworkPlaceholder extends StatelessWidget {
  const _StationArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.image_outlined,
      color: AppColors.artworkGlyph,
      size: 32,
    );
  }
}
