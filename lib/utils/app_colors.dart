import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppColors {
  AppColors._();

  // Color Palette Constants
  static const Color nightBordeaux = Color(0xFF651926);
  static const Color coffeeBean = Color(0xFF0F0406);
  static const Color rosyGranite = Color(0xFF95929C);
  static const Color alabasterGrey = Color(0xFFE2DDE3);
  static const Color mauveShadow = Color(0xFF462831);

  // Dynamic getters based on active theme
  static Color get primary => ThemeManager.isDark ? rosyGranite : nightBordeaux;
  static Color get primaryDark => ThemeManager.isDark ? coffeeBean : nightBordeaux;
  static Color get accent => ThemeManager.isDark ? nightBordeaux : mauveShadow;

  static Color get background => ThemeManager.isDark ? coffeeBean : alabasterGrey;
  static Color get card => ThemeManager.isDark ? mauveShadow : Colors.white;

  static Color get textPrimary => ThemeManager.isDark ? alabasterGrey : coffeeBean;
  static Color get textSecondary => ThemeManager.isDark ? rosyGranite : mauveShadow;

  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color danger = Colors.red;

  static const Color white = Colors.white;
}