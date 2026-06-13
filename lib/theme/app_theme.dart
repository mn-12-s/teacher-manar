import 'package:flutter/material.dart';

/// ألوان مطابقة للملف الأصلي (بوابة المدرسين).
class AppColors {
  static const primary = Color(0xFF1A3A5C); // --pr
  static const primaryLight = Color(0xFF2563A8); // --pl
  static const accent = Color(0xFFF0A500); // --ac
  static const ok = Color(0xFF06A77D); // حاضر
  static const no = Color(0xFFD62839); // غائب
  static const warn = Color(0xFFF59E0B); // مجاز
  static const bg = Color(0xFFF0F4F8);
  static const surface = Colors.white;
  static const muted = Color(0xFF64748B);
  static const text = Color(0xFF1E293B);
  static const border = Color(0xFFDDE3EC);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: 'Cairo',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
