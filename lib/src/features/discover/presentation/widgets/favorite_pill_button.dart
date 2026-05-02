import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/localizable.dart';

class FavoritePillButton extends StatelessWidget {
  const FavoritePillButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;
    final icon = Icon(
      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
    );
    final label = Text(
      isFavorite ? Localizable.savedFavorite.text : Localizable.favorite.text,
    );

    if (isFavorite) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.brand,
          foregroundColor: colors.onBrand,
          minimumSize: const Size(44, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: icon,
        label: label,
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.brand,
        minimumSize: const Size(44, 40),
        side: BorderSide(color: colors.brand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: icon,
      label: label,
    );
  }
}
