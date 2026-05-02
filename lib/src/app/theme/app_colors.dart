import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF07101F);
  static const inkMuted = Color(0xFF596272);
  static const paper = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFD6DAE2);
  static const softLine = Color(0xFFE9ECF2);
  static const brand = Color(0xFF081226);
  static const teal = Color(0xFF006D77);
  static const amber = Color(0xFFFFB703);
  static const danger = Color(0xFFD64545);
  static const artworkBase = Color(0xFFE9EBEF);
  static const artworkGlyph = Color(0xFF9AA1AC);
}

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ink,
    required this.inkMuted,
    required this.paper,
    required this.surface,
    required this.line,
    required this.softLine,
    required this.brand,
    required this.onBrand,
    required this.teal,
    required this.danger,
    required this.artworkBase,
    required this.artworkGlyph,
    required this.shadow,
  });

  final Color ink;
  final Color inkMuted;
  final Color paper;
  final Color surface;
  final Color line;
  final Color softLine;
  final Color brand;
  final Color onBrand;
  final Color teal;
  final Color danger;
  final Color artworkBase;
  final Color artworkGlyph;
  final Color shadow;

  static const light = AppPalette(
    ink: AppColors.ink,
    inkMuted: AppColors.inkMuted,
    paper: AppColors.paper,
    surface: AppColors.surface,
    line: AppColors.line,
    softLine: AppColors.softLine,
    brand: AppColors.brand,
    onBrand: AppColors.surface,
    teal: AppColors.teal,
    danger: AppColors.danger,
    artworkBase: AppColors.artworkBase,
    artworkGlyph: AppColors.artworkGlyph,
    shadow: AppColors.ink,
  );

  static const dark = AppPalette(
    ink: Color(0xFFF3F7FB),
    inkMuted: Color(0xFFAFB8C6),
    paper: Color(0xFF0B111B),
    surface: Color(0xFF121A26),
    line: Color(0xFF2B3746),
    softLine: Color(0xFF1B2634),
    brand: Color(0xFF9CC8FF),
    onBrand: Color(0xFF07101F),
    teal: Color(0xFF4FB8C2),
    danger: Color(0xFFFF7A7A),
    artworkBase: Color(0xFF1E2938),
    artworkGlyph: Color(0xFF8792A1),
    shadow: Color(0xFF000000),
  );

  @override
  AppPalette copyWith({
    Color? ink,
    Color? inkMuted,
    Color? paper,
    Color? surface,
    Color? line,
    Color? softLine,
    Color? brand,
    Color? onBrand,
    Color? teal,
    Color? danger,
    Color? artworkBase,
    Color? artworkGlyph,
    Color? shadow,
  }) {
    return AppPalette(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      paper: paper ?? this.paper,
      surface: surface ?? this.surface,
      line: line ?? this.line,
      softLine: softLine ?? this.softLine,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
      teal: teal ?? this.teal,
      danger: danger ?? this.danger,
      artworkBase: artworkBase ?? this.artworkBase,
      artworkGlyph: artworkGlyph ?? this.artworkGlyph,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }

    return AppPalette(
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      line: Color.lerp(line, other.line, t)!,
      softLine: Color.lerp(softLine, other.softLine, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      artworkBase: Color.lerp(artworkBase, other.artworkBase, t)!,
      artworkGlyph: Color.lerp(artworkGlyph, other.artworkGlyph, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get appPalette {
    final theme = Theme.of(this);
    return theme.extension<AppPalette>() ??
        (theme.brightness == Brightness.dark
            ? AppPalette.dark
            : AppPalette.light);
  }
}
