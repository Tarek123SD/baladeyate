/// Central registry for bundled image and vector assets.
abstract final class AppAssets {
  AppAssets._();

  static const String _images = 'assets/images';

  /// Default full-screen background (SVG pattern).
  static const String screenBackground = '$_images/pattern_exact.svg';

  /// Light textured background used on most screens.
  static const String backgroundWhite = '$_images/background_white.png';

  /// Splash and hero wallpaper.
  static const String splashWallpaper = '$_images/splash_screen_wallpaper.png';

  /// Decorative pattern asset.
  static const String patternExact = '$_images/pattern_exact.svg';

  /// Gold emblem shown on auth and splash screens.
  static const String logoGold = '$_images/Syrian_logo_icon_gold.png';

  /// Horizontal logo in the app bar.
  static const String logoHorizontalDarkGreen =
      '$_images/Syrian_horizontal_dark_green.png';
}
