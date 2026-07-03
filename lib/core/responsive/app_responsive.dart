import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

export 'package:responsive_x_toolkit/responsive_x.dart';
export 'dimensions.dart';
export 'responsive_helper.dart';

/// Semantic responsive helpers for baladeyate screens and widgets.
class AppResponsive {
  AppResponsive._();

  static double fontSmall(BuildContext context) =>
      Dimensions.font(12, context);
  static double fontDefault(BuildContext context) =>
      Dimensions.font(14, context);
  static double fontLarge(BuildContext context) =>
      Dimensions.font(16, context);
  static double fontTitle(BuildContext context) =>
      Dimensions.font(20, context);
  static double fontHeadline(BuildContext context) =>
      Dimensions.font(26, context);

  static double spacingSmall(BuildContext context) =>
      Dimensions.pad(10, context);
  static double spacingDefault(BuildContext context) =>
      Dimensions.pad(16, context);
  static double spacingLarge(BuildContext context) =>
      Dimensions.pad(24, context);

  static double radiusDefault(BuildContext context) =>
      Dimensions.rad(Dimensions.radiusDefault, context);

  static double bottomNavHeight(BuildContext context) =>
      Dimensions.height(72, context);
}

extension ResponsiveContext on BuildContext {
  double dim(double base) => base.s(this);
  double text(double base) => base.f(this);
  double iconSize(double base) => base.ic(this);
  double cornerRadius(double base) => base.r(this);
}
