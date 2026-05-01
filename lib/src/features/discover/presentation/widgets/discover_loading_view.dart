import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_loading_block.dart';
import 'discover_header.dart';

class DiscoverLoadingView extends StatelessWidget {
  const DiscoverLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        DiscoverHeader(),
        SizedBox(height: AppSpacing.lg),
        AppLoadingBlock(height: 52),
        SizedBox(height: AppSpacing.lg),
        AppLoadingBlock(height: 128),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            AppLoadingBlock(width: 82, height: 34),
            SizedBox(width: AppSpacing.sm),
            AppLoadingBlock(width: 72, height: 34),
            SizedBox(width: AppSpacing.sm),
            AppLoadingBlock(width: 72, height: 34),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        _StationLoadingRow(),
        _StationLoadingRow(),
        _StationLoadingRow(),
        _StationLoadingRow(),
      ],
    );
  }
}

class _StationLoadingRow extends StatelessWidget {
  const _StationLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: const [
          AppLoadingBlock(width: 70, height: 70),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLoadingBlock(width: 160, height: 16),
                SizedBox(height: AppSpacing.sm),
                AppLoadingBlock(width: 120, height: 14),
                SizedBox(height: AppSpacing.sm),
                AppLoadingBlock(width: 180, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
