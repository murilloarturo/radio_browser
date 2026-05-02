import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radii.dart';

class AppLoadingBlock extends StatelessWidget {
  const AppLoadingBlock({
    required this.height,
    this.width,
    this.borderRadius = AppRadii.sm,
    super.key,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.softLine,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: SizedBox(width: width, height: height),
    );
  }
}
