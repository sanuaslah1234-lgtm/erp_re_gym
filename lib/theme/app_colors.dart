import 'package:flutter/material.dart';

class AppColors {
  // =========================
  // PRIMARY
  // =========================

  static const primary = Color(0xFF2563EB);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primaryDarker = Color(0xFF1E40AF);
  static const primaryDarkest = Color(0xFF1E3A8A);

  static const primaryLight = Color(0xFFDBEAFE);
  static const primarySoft = Color(0xFFEFF6FF);

  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF3B82F6);

  // =========================
  // BACKGROUND
  // =========================

  static const background = Color(0xFFF8FAFC);
  static const pageBackground = Color(0xFFF1F5F9);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceSecondary = Color(0xFFF8FAFC);

  static const hoverBackground = Color(0xFFF1F5F9);
  static const selectedBackground = Color(0xFFEFF6FF);


  static const transparent = Colors.transparent;
  // =========================
  // TEXT
  // =========================

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const textDisabled = Color(0xFFCBD5E1);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // =========================
  // BORDER
  // =========================

  static const border = Color(0xFFE2E8F0);
  static const borderLight = Color(0xFFF1F5F9);
  static const borderMedium = Color(0xFFCBD5E1);

  // =========================
  // SUCCESS
  // =========================

  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFDCFCE7);
  static const successDark = Color(0xFF15803D);
  static const successText = Color(0xFF166534);

  // =========================
  // WARNING
  // =========================

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFD97706);
  static const warningText = Color(0xFF92400E);

  // =========================
  // INFO
  // =========================

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoDark = Color(0xFF1D4ED8);
  static const infoText = Color(0xFF1E40AF);

  // =========================
  // DANGER
  // =========================

  static const danger = Color(0xFFEF4444);
  static const dangerLight = Color(0xFFFEE2E2);
  static const dangerDark = Color(0xFFDC2626);
  static const dangerText = Color(0xFF991B1B);

  // =========================
  // NEUTRAL
  // =========================

  static const neutral = Color(0xFF64748B);
  static const neutralLight = Color(0xFFF1F5F9);
  static const neutralDark = Color(0xFF475569);
  static const neutralText = Color(0xFF334155);

  // =========================
  // CHART COLORS
  // =========================

  static const revenue = Color(0xFF2563EB);
  static const expenses = Color(0xFFEF4444);

  static const accessories = Color(0xFF2563EB);
  static const electronics = Color(0xFF6366F1);
  static const fashion = Color(0xFF16A34A);
  static const homeLiving = Color(0xFFF59E0B);
  static const others = Color(0xFFEF4444);

  static const medium = [
    BoxShadow(
      color: Color(0x0F0F172A), // 6%
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
  ];
  // =========================
  // CHART LIST
  // =========================

  static const chartColors = [
    accessories,
    electronics,
    fashion,
    homeLiving,
    others,
  ];
}
class AppShadows {
  // Very subtle – dashboard cards
  static const soft = [
    BoxShadow(
      color: Color(0x0A0F172A), // 4%
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // Normal card
  static const medium = [
    BoxShadow(
      color: Color(0x0F0F172A), // 6%
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
  ];

  // Elevated card
  static const elevated = [
    BoxShadow(
      color: Color(0x190F172A), // 10%
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  // Dialog / popup
  static const strong = [
    BoxShadow(
      color: Color(0x240F172A), // 14%
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  // Blue button
  static const primary = [
    BoxShadow(
      color: Color(0x1F2563EB), // 12%
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  // Success button
  static const success = [
    BoxShadow(
      color: Color(0x1F16A34A),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  // Danger button
  static const danger = [
    BoxShadow(
      color: Color(0x1FEF4444),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}