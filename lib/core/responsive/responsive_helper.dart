import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResponsiveHelper {
  ResponsiveHelper._();

  static bool isMobile(BuildContext context) => context.isMobile;

  static bool isTablet(BuildContext context) => context.isTablet;

  static bool isDesktop(BuildContext context) => context.isDesktop;

  static bool isWeb() => kIsWeb;

  static double horizontalPadding(BuildContext context) {
    return isMobile(context) ? 16.w(context) : 24.w(context);
  }

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return Dimensions.webMaxWidth.w(context);
    }
    if (isTablet(context)) {
      return Dimensions.contentMaxWidth.w(context);
    }
    return MediaQuery.sizeOf(context).width;
  }

  /// Width for a two-column row inside padded content.
  static double halfColumnWidth(
    BuildContext context, {
    required double availableWidth,
    double gap = 16,
  }) {
    return (availableWidth - Dimensions.pad(gap, context)) / 2;
  }
}
