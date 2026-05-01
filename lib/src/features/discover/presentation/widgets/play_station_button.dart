import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PlayStationButton extends StatelessWidget {
  const PlayStationButton({required this.onPressed, this.label, super.key});

  final VoidCallback onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return IconButton.filled(
        tooltip: 'Play station',
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.brand,
          side: const BorderSide(color: AppColors.ink),
          minimumSize: const Size.square(44),
        ),
        icon: const Icon(Icons.play_arrow_rounded),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.play_arrow_rounded),
      label: Text(label!),
    );
  }
}
