// lib/core/theme/app_colors.dart
//
// Nguồn giá trị: RFC-011 (Design System — Theme Tokens), Mục 3.
// KHÔNG sửa mã màu trực tiếp ở đây mà không cập nhật RFC-011 trước
// (theo quy trình RFC Amendment — xem docs/rfc/README.md).

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Primary Scale (Xanh lá đậm) — RFC-011 Mục 3.1
  // ---------------------------------------------------------------------
  static const Color primary900 = Color(0xFF0B3D24);
  static const Color primary700 = Color(0xFF145C36); // Primary chính
  static const Color primary500 = Color(0xFF1E7D4C); // hover/pressed
  static const Color primary100 = Color(0xFFD7ECE1);
  static const Color primary50 = Color(0xFFF1F8F4);

  /// Alias ngắn gọn dùng trong Widget hàng ngày
  static const Color primary = primary700;

  // ---------------------------------------------------------------------
  // Neutral Scale — RFC-011 Mục 3.2
  // ---------------------------------------------------------------------
  static const Color neutral900 = Color(0xFF1A1D1E); // text chính
  static const Color neutral700 = Color(0xFF4A4F52); // text phụ
  static const Color neutral500 = Color(0xFF8B9194); // disabled/placeholder
  static const Color neutral300 = Color(0xFFD8DBDC); // border/divider
  static const Color neutral100 = Color(0xFFF2F3F3); // nền app
  static const Color neutral0 = Color(0xFFFFFFFF); // nền Card/Surface

  static const Color textPrimary = neutral900;
  static const Color textSecondary = neutral700;
  static const Color textDisabled = neutral500;
  static const Color border = neutral300;
  static const Color background = neutral100;
  static const Color surface = neutral0;

  // ---------------------------------------------------------------------
  // Semantic Colors — RFC-011 Mục 3.3
  // Ánh xạ trực tiếp với trạng thái entity ở RFC-006/007/008/010,
  // không tự đổi màu cho các trạng thái đó ở nơi khác.
  // ---------------------------------------------------------------------
  static const Color success = Color(0xFF1E7D4C); // = primary500
  static const Color warning = Color(0xFFC97A1E);
  static const Color error = Color(0xFFC23B3B);
  static const Color info = Color(0xFF2E6EA6);

  // ---------------------------------------------------------------------
  // Ánh xạ theo trạng thái nghiệp vụ cụ thể (tiện dùng trong code)
  // ---------------------------------------------------------------------

  /// RFC-006: memory_status
  static Color memoryStatusColor(String status) {
    switch (status) {
      case 'conflicting':
        return error;
      case 'confirmed':
        return success;
      case 'archived':
        return neutral500;
      case 'proposed':
      default:
        return info;
    }
  }

  /// RFC-006: memory_confidence — mức Low không nổi bật
  static Color memoryConfidenceColor(String confidence) {
    switch (confidence) {
      case 'high':
        return primary700;
      case 'medium':
        return info;
      case 'low':
      default:
        return neutral500;
    }
  }

  /// RFC-007: task_status
  static Color taskStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return success;
      case 'dismissed':
        return neutral500;
      case 'snoozed':
        return warning;
      case 'pending':
      default:
        return info;
    }
  }

  /// RFC-008: match_status — 'sent' quá hạn dùng warning ở tầng UI logic,
  /// không phải ở đây (đây chỉ trả màu theo status thô).
  static Color matchStatusColor(String status) {
    switch (status) {
      case 'viewed':
        return success;
      case 'rejected':
        return error;
      case 'sent':
        return info;
      case 'archived':
        return neutral500;
      case 'suggested':
      default:
        return neutral700;
    }
  }
}
