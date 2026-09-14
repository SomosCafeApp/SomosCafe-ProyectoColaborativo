import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // TEMA CLARO
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,

        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accentYellow,
          surface: AppColors.lightSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
        ),

        cardTheme: CardThemeData(
          color: AppColors.lightSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: AppColors.lightSurface,
          titleTextStyle: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          actionTextColor: AppColors.accentYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

  // TEMA OSCURO
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accentYellow,
          surface: AppColors.darkSurface,
          onPrimary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
        ),

        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: AppColors.darkSurface,
          titleTextStyle: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 13,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          actionTextColor: AppColors.accentYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
}