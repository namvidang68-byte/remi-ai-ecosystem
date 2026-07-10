// lib/core/theme/app_theme.dart
//
// Nguồn giá trị: RFC-011 (Design System — Theme Tokens), Mục 7.
// File này tổng hợp AppColors + AppTypography + AppSpacing thành
// ThemeData duy nhất cho MaterialApp. Mọi Widget nên dùng
// Theme.of(context) hoặc trực tiếp AppColors/AppTypography —
// KHÔNG định nghĩa style cục bộ trùng lặp.

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary700,
        primary: AppColors.primary700,
        secondary: AppColors.primary500,
        error: AppColors.error,
        surface: AppColors.surface,
        brightness: Brightness.light,
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
        labelLarge: AppTypography.button,
      ),

      // ---- Button (Primary) — RFC-011 Mục 7.1 ----
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary700,
          foregroundColor: AppColors.surface,
          disabledBackgroundColor: AppColors.neutral300,
          disabledForegroundColor: AppColors.neutral500,
          textStyle: AppTypography.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
        ),
      ),

      // ---- Card — RFC-011 Mục 7.2 ----
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: AppElevation.level1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),

      // ---- Input Field — RFC-011 Mục 7.3 ----
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textDisabled),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.primary700, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // ---- Bottom Navigation — khớp RFC-009 (4 mục cố định) ----
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary700,
        unselectedItemColor: AppColors.neutral500,
        selectedLabelStyle: AppTypography.caption,
        unselectedLabelStyle: AppTypography.caption,
        type: BottomNavigationBarType.fixed,
      ),

      dividerColor: AppColors.border,
    );
  }

  // Dark mode: chưa cần ở Giai đoạn 1 (RFC-009 Mục 4) — để trống có chủ đích,
  // không tự thêm khi chưa có RFC quyết định bảng màu dark.
}
