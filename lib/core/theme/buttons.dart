import 'package:flutter/material.dart';

class AppButtons {
  static ElevatedButtonThemeData elevated(ColorScheme cs) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
        ),
      );

  static OutlinedButtonThemeData outlined(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary, width: 1.4),
        ),
      );

  static TextButtonThemeData text(ColorScheme cs) => TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: cs.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
  );
}
