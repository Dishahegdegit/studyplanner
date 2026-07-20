import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppColors {
  AppColors._();

  // Color Palette Constants from UI Theme Guide
  static const Color linen = Color(0xFFF5E9E2);
  static const Color almondSilk = Color(0xFFE3B5A4);
  static const Color lobsterPink = Color(0xFFD44D5C);
  static const Color winePlum = Color(0xFF773344);
  static const Color midnightViolet = Color(0xFF160029);

  static const List<Color> subjectPalette = [
    Colors.red,
    Colors.yellow,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
  ];

  // Dynamic getters based on active theme
  // Primary actions & highlights use Lobster Pink
  static Color get primary => lobsterPink;
  static Color get primaryDark => winePlum;
  static Color get accent => lobsterPink;

  // Background is transparent to let the gradient scaffold background show through
  static Color get background => Colors.transparent;

  // Cards use Almond Silk & Linen in light mode, Wine Plum & Midnight Violet in dark mode
  static Color get card => ThemeManager.isDark ? winePlum : linen;
  static Color get cardSecondary => ThemeManager.isDark ? midnightViolet : almondSilk;
  static Color get cardTertiary => ThemeManager.isDark ? winePlum : Color(0xFFF8DED4);

  // Text remains clear and readable in both themes
  static Color get textPrimary => ThemeManager.isDark ? linen : midnightViolet;
  static Color get textSecondary => ThemeManager.isDark ? almondSilk : winePlum;
  static Color get textMuted => ThemeManager.isDark ? Color(0xFFCDAF9F) : Color(0xFF8A5A67);
  static Color get vividPink => ThemeManager.isDark ? const Color(0xFFFF8FA0) : lobsterPink;

  static const Color success = lobsterPink;
  static const Color warning = almondSilk;
  static const Color danger = winePlum;

  static const Color white = Colors.white;
  static const Color surfaceTint = Color(0x19D44D5C);
  static const Color surfaceTintDark = Color(0x33160029);

  static Decoration getBackgroundDecoration() {
    if (ThemeManager.isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0D0617), // Near-black violet
            midnightViolet,    // Deep midnight violet
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
      );
    } else {
      return const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEAD4CA),
            Color(0xFFE0C1B6),
            Color(0xFFD7A8A4),
            Color(0x52D44D5C), // Lobster Pink (soft)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
        ),
      );
    }
  }
}
