import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Centers content and caps width on large screens so forms stay readable.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxContentWidth = 560,
    this.horizontalPadding,
  });

  final Widget child;
  final double maxContentWidth;
  final double? horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final pad = horizontalPadding ?? 24.s(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.isDesktop ? maxContentWidth : double.infinity,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: child,
        ),
      ),
    );
  }
}
