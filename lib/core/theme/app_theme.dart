import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryGreen,
      secondary: AppColors.primaryBlue,
      tertiary: AppColors.primaryOrange,
      error: AppColors.error,
      surface: AppColors.backgroundLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.darkGray, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.mediumGray, fontSize: 14),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.offWhite,
      selectedColor: AppColors.secondaryGreen,
      disabledColor: AppColors.lightGray,
      labelStyle: const TextStyle(color: AppColors.darkGray, fontSize: 13),
      secondaryLabelStyle: const TextStyle(color: AppColors.white, fontSize: 13),
      side: const BorderSide(color: AppColors.lightGray),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.mediumGray,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.primaryGreen,
      unselectedLabelColor: AppColors.mediumGray,
      indicatorColor: AppColors.primaryGreen,
      dividerColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightGray,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.black),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
      headlineLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.black),
      headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.black),
      headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.black),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.black),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.black),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.darkGray),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.darkGray),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.darkGray),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.mediumGray),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkGray),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.mediumGray),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.mediumGray),
    ),
  );
}
