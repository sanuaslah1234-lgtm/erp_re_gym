import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // =========================
  // HEADINGS
  // =========================
  static const h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // =========================
  // BODY
  // =========================
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // =========================
  // SPECIAL TEXT
  // =========================
  static const subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
  );

  static const button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.3,
  );
}
