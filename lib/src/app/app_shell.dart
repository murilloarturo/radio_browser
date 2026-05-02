import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/discover/presentation/cubit/discover_cubit.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/favorites/presentation/pages/favorites_page.dart';
import 'di/service_locator.dart';
import 'navigation/app_bottom_navigation.dart';
import 'navigation/app_tab.dart';

class RadioBrowserShell extends StatefulWidget {
  const RadioBrowserShell({super.key});

  @override
  State<RadioBrowserShell> createState() => _RadioBrowserShellState();
}

class _RadioBrowserShellState extends State<RadioBrowserShell> {
  AppTab _selectedTab = AppTab.discover;

  void _selectTab(AppTab tab) {
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedTab.index,
        children: [
          const DiscoverEntryPoint(),
          FavoritesEntryPoint(
            onDiscoverRequested: () => _selectTab(AppTab.discover),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        selectedTab: _selectedTab,
        onTabSelected: _selectTab,
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
  const FavoritesEntryPoint({required this.onDiscoverRequested, super.key});

  final VoidCallback onDiscoverRequested;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoritesCubit>(
      create: (_) => getIt<FavoritesCubit>()..load(),
      child: FavoritesPage(onDiscoverRequested: onDiscoverRequested),
    );
  }
}
