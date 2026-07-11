import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (MediaQuery.sizeOf(context).width * devicePixelRatio)
        .round()
        .clamp(360, 1440);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ResizeImage(
              AssetImage(AppAssets.backgroundWhite),
              width: cacheWidth,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}
