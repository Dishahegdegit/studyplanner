import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static void toggleTheme() {
    themeMode.value = themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => themeMode.value == ThemeMode.dark;
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.light(
      primary: AppColors.lobsterPink,
      secondary: AppColors.almondSilk,
      surface: AppColors.linen,
      onPrimary: Colors.white,
      onSurface: AppColors.midnightViolet,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.midnightViolet,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.midnightViolet,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.midnightViolet),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.linen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.winePlum.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lobsterPink, width: 1.8),
      ),
      labelStyle: const TextStyle(color: AppColors.winePlum),
      hintStyle: TextStyle(color: AppColors.winePlum.withValues(alpha: 0.7)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.linen,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.almondSilk.withValues(alpha: 0.35),
      selectedColor: AppColors.lobsterPink,
      labelStyle: const TextStyle(color: AppColors.midnightViolet),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      side: BorderSide(color: AppColors.winePlum.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lobsterPink,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lobsterPink,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.linen,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppColors.lobsterPink,
      unselectedItemColor: AppColors.winePlum,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lobsterPink,
      unselectedLabelColor: AppColors.winePlum,
      indicatorColor: AppColors.lobsterPink,
      dividerColor: Colors.transparent,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.midnightViolet,
      contentTextStyle: const TextStyle(color: AppColors.linen),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.midnightViolet, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.midnightViolet, fontSize: 14),
      titleLarge: TextStyle(color: AppColors.midnightViolet, fontWeight: FontWeight.bold),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.lobsterPink,
      secondary: AppColors.winePlum,
      surface: AppColors.winePlum,
      onPrimary: Colors.white,
      onSurface: AppColors.linen,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.linen,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.linen,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.linen),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.winePlum.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.almondSilk.withValues(alpha: 0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.lobsterPink, width: 1.8),
      ),
      labelStyle: const TextStyle(color: AppColors.almondSilk),
      hintStyle: TextStyle(color: AppColors.almondSilk.withValues(alpha: 0.65)),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.winePlum,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.midnightViolet.withValues(alpha: 0.45),
      selectedColor: AppColors.lobsterPink,
      labelStyle: const TextStyle(color: AppColors.linen),
      secondaryLabelStyle: const TextStyle(color: AppColors.midnightViolet),
      side: BorderSide(color: AppColors.almondSilk.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.lobsterPink,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lobsterPink,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.winePlum,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: AppColors.lobsterPink,
      unselectedItemColor: AppColors.almondSilk,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.lobsterPink,
      unselectedLabelColor: AppColors.almondSilk,
      indicatorColor: AppColors.lobsterPink,
      dividerColor: Colors.transparent,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.midnightViolet,
      contentTextStyle: const TextStyle(color: AppColors.linen),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.linen, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.linen, fontSize: 14),
      titleLarge: TextStyle(color: AppColors.linen, fontWeight: FontWeight.bold),
    ),
  );
}
