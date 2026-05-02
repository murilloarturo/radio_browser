import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/localizable.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return IconButton(
      tooltip:
          isFavorite
              ? Localizable.removeFavorite.text
              : Localizable.addFavorite.text,
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: isFavorite ? colors.danger : colors.ink,
      ),
    );
  }
}
