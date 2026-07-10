// lib/core/theme/app_spacing.dart
//
// Nguồn giá trị: RFC-011 (Design System — Theme Tokens), Mục 5 & 6.
// Thang bội số 4px cho spacing; radius/elevation dùng chung file này
// vì cùng thuộc nhóm "layout token" cấp thấp.

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();

  static const double sm = 6; // input field, badge nhỏ
  static const double md = 12; // Card, Button — mặc định
  static const double lg = 20; // Bottom Sheet, Modal
}

class AppElevation {
  AppElevation._();

  static const double level1 = 1; // Card thường
  static const double level2 = 4; // Card đang tương tác, FAB
}
