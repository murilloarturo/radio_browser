import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/discover/presentation/cubit/discover_cubit.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import 'di/service_locator.dart';
import 'navigation/app_bottom_navigation.dart';
import 'navigation/app_tab.dart';
import 'theme/app_colors.dart';

class RadioBrowserShell extends StatefulWidget {
  const RadioBrowserShell({super.key});

  @override
  State<RadioBrowserShell> createState() => _RadioBrowserShellState();
}

class _RadioBrowserShellState extends State<RadioBrowserShell> {
  AppTab _selectedTab = AppTab.discover;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: IndexedStack(
        index: _selectedTab.index,
        children: const [DiscoverEntryPoint(), FavoritesEntryPoint()],
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
    );
  }
}

class DiscoverEntryPoint extends StatelessWidget {
  const DiscoverEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscoverCubit>(
      create: (_) => getIt<DiscoverCubit>()..load(),
      child: const DiscoverPage(),
    );
  }
}

class FavoritesEntryPoint extends StatelessWidget {
  const FavoritesEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoritesCubit>(
      create: (_) => getIt<FavoritesCubit>()..load(),
      child: const FavoritesPage(),
    );
  }
}
