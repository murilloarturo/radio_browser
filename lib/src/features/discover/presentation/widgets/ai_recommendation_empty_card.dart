import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radii.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/assets/app_assets.dart';
import '../../../../core/localization/localizable.dart';

class AiRecommendationEmptyCard extends StatelessWidget {
  const AiRecommendationEmptyCard({required this.isLoading, super.key});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizable.recommendedForYou.text,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(AppRadii.sm),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.04),
                offset: const Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Image.asset(
                    AppAssets.botRadioIllustration,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    semanticLabel: Localizable.recommendedForYou.text,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLoading
                            ? Localizable.aiRecommendationLoadingTitle.text
                            : Localizable.aiRecommendationEmptyTitle.text,
                        style: textTheme.titleSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        isLoading
                            ? Localizable.aiRecommendationLoadingMessage.text
                            : Localizable.aiRecommendationEmptyMessage.text,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: AppSpacing.md),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
