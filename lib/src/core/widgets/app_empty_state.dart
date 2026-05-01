import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    required this.message,
    this.assetPath,
    this.assetSemanticLabel,
    super.key,
  });

  final String title;
  final String message;
  final String? assetPath;
  final String? assetSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath == null)
              const Icon(
                Icons.radio_outlined,
                size: 40,
                color: AppColors.inkMuted,
              )
            else
              Image.asset(
                assetPath!,
                height: 220,
                fit: BoxFit.contain,
                semanticLabel: assetSemanticLabel ?? title,
              ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
