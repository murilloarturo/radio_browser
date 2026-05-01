import 'package:flutter/material.dart';

import '../core/localization/localizable.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

class RadioBrowserApp extends StatelessWidget {
  const RadioBrowserApp({super.key, this.home});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Localizable.appTitle.text,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: home ?? const RadioBrowserShell(),
    );
  }
}
