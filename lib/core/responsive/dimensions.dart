import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Design tokens and responsive scaling helpers (responsive_x_toolkit).
class Dimensions {
  Dimensions._();

  static const double paddingSizeExtraSmall = 5;
  static const double paddingSizeSmall = 10;
  static const double paddingSizeDefault = 15;
  static const double paddingSizeLarge = 20;
  static const double paddingSizeExtraLarge = 25;

  static const double radiusSmall = 8;
  static const double radiusDefault = 12;
  static const double radiusLarge = 16;
  static const double radiusExtraLarge = 20;

  /// Max readable content width on tablet/desktop.
  static const double contentMaxWidth = 760;
  static const double formMaxWidth = 560;
  static const double webMaxWidth = 1170;

  static double pad(double base, BuildContext context) => base.s(context);
  static double height(double base, BuildContext context) => base.h(context);
  static double width(double base, BuildContext context) => base.w(context);
  static double rad(double base, BuildContext context) => base.r(context);
  static double font(double base, BuildContext context) => base.f(context);
  static double icon(double base, BuildContext context) => base.ic(context);

  static double get rPaddingDefault => paddingSizeDefault;
  static double rPaddingLarge(BuildContext context) =>
      pad(paddingSizeLarge, context);
}
