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
          backgroundColor: AppColors.brand,
          foregroundColor: AppColors.surface,
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
        foregroundColor: AppColors.brand,
        minimumSize: const Size(44, 40),
        side: const BorderSide(color: AppColors.brand),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: icon,
      label: label,
    );
  }
}
