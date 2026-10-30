import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFFD71920);
  static CupertinoThemeData cupertino(Brightness brightness) {
    final material = build(brightness);
    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: material.colorScheme.primary,
      primaryContrastingColor: material.colorScheme.onPrimary,
      scaffoldBackgroundColor: material.scaffoldBackgroundColor,
      barBackgroundColor: material.colorScheme.surface.withValues(alpha: .85),
      textTheme: CupertinoTextThemeData(
        primaryColor: material.colorScheme.primary,
      ),
    );
  }

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: dark ? const Color(0xFFFF8992) : primary,
      onPrimary: dark ? const Color(0xFF560510) : Colors.white,
      secondary: const Color(0xFFE53942),
      surface: dark ? const Color(0xFF2C1B20) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF160E11)
          : const Color(0xFFF5F5F7),
      fontFamilyFallback: const ['Noto Sans Khmer'],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: .12),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
