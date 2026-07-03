import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Centers content and caps width on large screens so forms stay readable.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxContentWidth = Dimensions.formMaxWidth,
    this.horizontalPadding,
  });

  final Widget child;
  final double maxContentWidth;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final pad = horizontalPadding ?? Dimensions.pad(Dimensions.paddingSizeLarge, context);
    final maxWidth = context.isDesktop || context.isTablet
        ? maxContentWidth.w(context)
        : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: child,
        ),
      ),
    );
  }
}

/// Centers scrollable/page content with a max width on tablet and desktop.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = Dimensions.contentMaxWidth,
    this.padding,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final horizontal = ResponsiveHelper.horizontalPadding(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth.w(context)),
        child: Padding(
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: horizontal,
                vertical: Dimensions.pad(18, context),
              ),
          child: child,
        ),
      ),
    );
  }
}
