import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Centralized light and dark themes.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        fontFamily: 'Alyamama',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryForest,
          brightness: Brightness.light,
        ),
        primaryColor: AppColors.primaryForest,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.thirdCharcoal,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF616161),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        fontFamily: 'Alyamama',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryForest,
          brightness: Brightness.dark,
        ),
        primaryColor: AppColors.primaryForest,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryCharcoal,
          foregroundColor: Colors.white,
        ),
      );
}
