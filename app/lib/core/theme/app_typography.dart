// lib/core/theme/app_typography.dart
//
// Nguồn giá trị: RFC-011 (Design System — Theme Tokens), Mục 4.
// Font: Be Vietnam Pro (qua package google_fonts) — hỗ trợ đầy đủ
// dấu thanh điệu tiếng Việt.
//
// Thêm vào pubspec.yaml:
//   dependencies:
//     google_fonts: ^6.2.1

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight weight,
    required double height,
    Color color = AppColors.textPrimary,
  }) {
    return GoogleFonts.beVietnamPro(
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
      color: color,
    );
  }

  // Hiếm dùng — màn hình chào mừng/onboarding
  static TextStyle display = _base(
    fontSize: 32,
    weight: FontWeight.w700,
    height: 1.25,
  );

  // Tiêu đề màn hình (VD: "Chi tiết Lead")
  static TextStyle heading1 = _base(
    fontSize: 24,
    weight: FontWeight.w700,
    height: 1.3,
  );

  // Tiêu đề section/tab
  static TextStyle heading2 = _base(
    fontSize: 20,
    weight: FontWeight.w600,
    height: 1.3,
  );

  // Tiêu đề card, item quan trọng
  static TextStyle heading3 = _base(
    fontSize: 16,
    weight: FontWeight.w600,
    height: 1.4,
  );

  // Nội dung chính, mô tả
  static TextStyle bodyLarge = _base(
    fontSize: 16,
    weight: FontWeight.w400,
    height: 1.5,
  );

  // Nội dung phụ, list item — dùng nhiều nhất trong app
  static TextStyle body = _base(
    fontSize: 14,
    weight: FontWeight.w400,
    height: 1.5,
  );

  // Label, timestamp, metadata phụ
  static TextStyle caption = _base(
    fontSize: 12,
    weight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  // Chữ trên nút bấm
  static TextStyle button = _base(
    fontSize: 14,
    weight: FontWeight.w600,
    height: 1.2,
    color: AppColors.surface,
  );
}
