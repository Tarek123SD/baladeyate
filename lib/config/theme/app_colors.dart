import 'package:flutter/material.dart';

/// App-wide color palette.
class AppColors {
  AppColors._();

  // Forest Colors
  static const Color primaryForest = Color(0xFF0B4D3C);
  static const Color secondaryForest = Color(0xFF054239);
  static const Color thirdForest = Color(0xFF428177);
  static const Color green = Color(0xFF0B4D3C);

  // Background & Surface
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // Golden Wheat Colors
  static const Color primaryGoldenWheat = Color(0xFF988561);
  static const Color secondaryGoldenWheat = Color(0xFFB9A779);
  static const Color thirdGoldenWheat = Color(0xFFEDEBE0);

  // Deep Umber Colors
  static const Color primaryDeepUmber = Color(0xFF260F14);
  static const Color secondaryDeepUmber = Color(0xFF4A151E);
  static const Color thirdDeepUmber = Color(0xFF6B1F2A);

  // Charcoal Colors
  static const Color primaryCharcoal = Color(0xFF161616);
  static const Color secondaryCharcoal = Color(0xFF3D3A3B);
  static const Color thirdCharcoal = Color(0xFFFFFFFF);

  // Feedback Colors
  static const Color alertRed = Color(0xFFD32F2F);

  // Input Field Colors
  /// Soft mist-green background used for text fields.
  static const Color inputFill = Color(0xFFFAFAFA);

  /// Subtle resting border for text fields.
  static const Color inputBorder = Color(0xFFE5E7EB);

  /// Border color when a text field is focused.
  static const Color inputFocusedBorder = green;
}
