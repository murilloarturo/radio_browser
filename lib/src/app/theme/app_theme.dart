import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const palette = AppPalette.light;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.teal,
        brightness: Brightness.light,
        primary: palette.brand,
        onPrimary: palette.onBrand,
        secondary: palette.teal,
        surface: palette.surface,
        error: palette.danger,
      ),
      extensions: const [palette],
      scaffoldBackgroundColor: palette.paper,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: palette.paper,
        foregroundColor: palette.ink,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brand,
          foregroundColor: palette.onBrand,
          minimumSize: const Size(44, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brand,
          side: BorderSide(color: palette.brand),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.brand,
        contentTextStyle: TextStyle(color: palette.onBrand),
        closeIconColor: palette.onBrand,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: palette.line),
      useMaterial3: true,
    );
  }

  static ThemeData get dark {
    const palette = AppPalette.dark;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.teal,
        brightness: Brightness.dark,
        primary: palette.brand,
        onPrimary: palette.onBrand,
        secondary: palette.teal,
        surface: palette.surface,
        error: palette.danger,
      ),
      extensions: const [palette],
      scaffoldBackgroundColor: palette.paper,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: palette.paper,
        foregroundColor: palette.ink,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brand,
          foregroundColor: palette.onBrand,
          minimumSize: const Size(44, 40),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brand,
          side: BorderSide(color: palette.brand),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surface,
        contentTextStyle: TextStyle(color: palette.ink),
        closeIconColor: palette.ink,
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: palette.line),
      useMaterial3: true,
    );
  }
}
