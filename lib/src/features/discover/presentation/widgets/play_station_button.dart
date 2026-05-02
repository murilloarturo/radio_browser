import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/localization/localizable.dart';

class PlayStationButton extends StatelessWidget {
  const PlayStationButton({
    required this.onPressed,
    this.label,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback onPressed;
  final Localizable? label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    if (label == null) {
      return IconButton.filled(
        tooltip: Localizable.playStation.text,
        onPressed: isLoading ? null : onPressed,
        style: IconButton.styleFrom(
          backgroundColor: colors.surface,
          foregroundColor: colors.brand,
          side: BorderSide(color: colors.ink),
          minimumSize: const Size.square(44),
        ),
        icon:
            isLoading
                ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.play_arrow_rounded),
      );
    }

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon:
          isLoading
              ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.play_arrow_rounded),
      label: Text(label!.text),
    );
  }
}
