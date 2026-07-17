import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppStyles {
  AppStyles._();

  static TextStyle get heading => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static TextStyle get body => TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,

      filled: true,
      fillColor: AppColors.card,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.textMuted.withValues(alpha: 0.35),
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    );
  }
}
