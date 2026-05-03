// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primaryGreen = Color(0xFF1A7A4A);
  static const Color primaryBlue = Color(0xFF1C4E80);
  static const Color primaryOrange = Color(0xFFD46B08);
  
  // Secondary colors
  static const Color secondaryGreen = Color(0xFF2E9E64);
  static const Color secondaryBlue = Color(0xFF2A6B9E);
  static const Color secondaryOrange = Color(0xFFFA8C16);
  
  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color lightGray = Color(0xFFE0E0E0);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color black = Color(0xFF212121);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  
  // Card and surface colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1E1E1E);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOrange, secondaryOrange],
  );
  
  // Shadow
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
}
