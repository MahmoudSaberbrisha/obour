import 'package:flutter/material.dart';

import 'buttons.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get light {
    const seed = Color.fromARGB(255, 51, 214, 105);
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );
    final colorScheme = base.copyWith(
      primary: seed,
      onPrimary: Colors.white,
      secondary: seed,
      tertiary: seed,
      surface: Colors.white,
      background: const Color(0xFFF6F6F6),
      surfaceContainer: Colors.white,
      surfaceContainerHigh: const Color(0xFFFDFDFD),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      canvasColor: Colors.white,
      textTheme: AppTypography.textTheme,
      elevatedButtonTheme: AppButtons.elevated(colorScheme),
      outlinedButtonTheme: AppButtons.outlined(colorScheme),
      textButtonTheme: AppButtons.text(colorScheme),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.55),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        centerTitle: true,
        scrolledUnderElevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.65),
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.85),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 8,
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: seed.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colorScheme.primary : Colors.grey.shade700,
            size: selected ? 28 : 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colorScheme.primary : Colors.grey.shade700,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData get dark {
    const seed = Color(0xFF4ADE80);
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    );
    final colorScheme = base.copyWith(
      primary: const Color(0xFF4ADE80),
      onPrimary: const Color(0xFF062B25),
      secondary: const Color(0xFF38BDF8),
      tertiary: const Color(0xFF7DD3FC),
      surface: const Color(0xFF111827),
      surfaceVariant: const Color(0xFF1F2937),
      background: const Color(0xFF0B1120),
      onSurface: Colors.white,
      onSurfaceVariant: const Color(0xFF9CA3AF),
      outline: const Color(0xFF1F2933),
      outlineVariant: const Color(0xFF1F2933),
    );

    final textTheme = AppTypography.textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      canvasColor: const Color(0xFF0B1120),
      textTheme: textTheme,
      elevatedButtonTheme: AppButtons.elevated(colorScheme),
      outlinedButtonTheme: AppButtons.outlined(colorScheme),
      textButtonTheme: AppButtons.text(colorScheme),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.55),
        surfaceTintColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.65),
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1F2937),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.85),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: Colors.white,
        indicatorColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? Colors.black : const Color(0xFF6B7280),
            size: selected ? 28 : 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.black : const Color(0xFF6B7280),
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary.withOpacity(0.9),
        foregroundColor: const Color(0xFF042F2E),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(16),
        ),
        fillColor: colorScheme.surfaceVariant,
        filled: true,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
