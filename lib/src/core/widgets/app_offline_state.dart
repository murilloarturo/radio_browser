import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../assets/app_assets.dart';
import '../localization/localizable.dart';

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              AppAssets.offlineIllustration,
              height: 220,
              semanticsLabel: Localizable.noConnectionTitle.text,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              Localizable.noConnectionTitle.text,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              Localizable.noConnectionMessage.text,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.inkMuted,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(Localizable.retry.text),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
