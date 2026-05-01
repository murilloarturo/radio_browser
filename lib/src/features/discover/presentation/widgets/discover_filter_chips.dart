import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/localization/localizable.dart';
import '../cubit/discover_filter.dart';

class DiscoverFilterChips extends StatelessWidget {
  const DiscoverFilterChips({
    required this.activeFilter,
    required this.onFilterSelected,
    super.key,
  });

  final DiscoverFilter activeFilter;
  final ValueChanged<DiscoverFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DiscoverFilter.defaults.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = DiscoverFilter.defaults[index];
          final isSelected = filter == activeFilter;

          return ChoiceChip(
            label: Text(filter.labelKey.text),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onFilterSelected(filter),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.surface : AppColors.ink,
              fontWeight: FontWeight.w600,
            ),
            selectedColor: AppColors.brand,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.brand : AppColors.line,
            ),
          );
        },
      ),
    );
  }
}
