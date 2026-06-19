import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Full-screen background isolated from keyboard-driven layout changes.
class FixedScreenBackground extends StatefulWidget {
  const FixedScreenBackground({
    super.key,
    this.assetPath = AppAssets.screenBackground,
  });

  final String assetPath;

  static bool isSvg(String path) => path.toLowerCase().endsWith('.svg');

  static int cacheWidthFor(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = MediaQuery.sizeOf(context).width;
    return (width * dpr).round();
  }

  static ImageProvider providerFor(BuildContext context, String assetPath) {
    return ResizeImage(
      AssetImage(assetPath),
      width: cacheWidthFor(context),
    );
  }

  static Future<void> precache(
    BuildContext context, [
    String assetPath = AppAssets.screenBackground,
  ]) async {
    if (isSvg(assetPath)) {
      final loader = SvgAssetLoader(assetPath);
      await svg.cache.putIfAbsent(
        loader.cacheKey(null),
        () => loader.loadBytes(null),
      );
      return;
    }

    await precacheImage(providerFor(context, assetPath), context);
  }

  @override
  State<FixedScreenBackground> createState() => _FixedScreenBackgroundState();
}

class _FixedScreenBackgroundState extends State<FixedScreenBackground> {
  Size? _lockedSize;

  @override
  Widget build(BuildContext context) {
    _lockedSize ??= MediaQuery.sizeOf(context);
    final size = _lockedSize!;

    if (FixedScreenBackground.isSvg(widget.assetPath)) {
      return RepaintBoundary(
        child: SvgPicture.asset(
          widget.assetPath,
          fit: BoxFit.cover,
          width: size.width,
          height: size.height,
          clipBehavior: Clip.hardEdge,
          placeholderBuilder: (_) => const ColoredBox(color: Colors.white),
        ),
      );
    }

    final cacheWidth = FixedScreenBackground.cacheWidthFor(context);
    return RepaintBoundary(
      child: Image.asset(
        widget.assetPath,
        fit: BoxFit.cover,
        width: size.width,
        height: size.height,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.low,
        gaplessPlayback: true,
        isAntiAlias: false,
      ),
    );
  }
}
