import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../core/localization/localizable.dart';
import 'app_tab.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab selectedTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomNavItem(
                selectedIcon: Icons.home_rounded,
                unselectedIcon: Icons.home_outlined,
                label: Localizable.discoverTab,
                isSelected: selectedTab == AppTab.discover,
                onPressed: () => onTabSelected(AppTab.discover),
              ),
              _BottomNavItem(
                selectedIcon: Icons.favorite_rounded,
                unselectedIcon: Icons.favorite_border_rounded,
                label: Localizable.favoritesTab,
                isSelected: selectedTab == AppTab.favorites,
                onPressed: () => onTabSelected(AppTab.favorites),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final IconData selectedIcon;
  final IconData unselectedIcon;
  final Localizable label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.brand : AppColors.inkMuted;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: SizedBox(
          width: 112,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  key: ValueKey<bool>(isSelected),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
