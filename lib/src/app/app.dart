import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/discover/presentation/cubit/discover_cubit.dart';
import '../features/discover/presentation/pages/discover_page.dart';
import 'di/service_locator.dart';
import 'theme/app_theme.dart';

class RadioBrowserApp extends StatelessWidget {
  const RadioBrowserApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadioBrowser',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: home ?? const DiscoverEntryPoint(),
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
