import 'package:flutter/material.dart';

/// CustomPainter that renders a dark semi-transparent overlay around
/// a square scanning area in the center with rounded corners and glowing borders.
class ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color borderColor;
  final double scanWindowSize;
  final double borderRadius;
  final double borderWidth;

  ScannerOverlayPainter({
    this.overlayColor = const Color(0xB3000000), // 70% black
    this.borderColor = const Color(0xFFB9A779), // Golden wheat accent
    this.scanWindowSize = 260.0,
    this.borderRadius = 16.0,
    this.borderWidth = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double windowSize =
        scanWindowSize > size.width - 40 ? size.width - 40 : scanWindowSize;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: windowSize,
      height: windowSize,
    );

    // 1. Draw dark background cutout
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius)));

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final Paint backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, backgroundPaint);

    // 2. Draw subtle border around scanning area
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final RRect rrect = RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, borderPaint);

    // 3. Draw corner highlight brackets for scanner guidance
    final double cornerLength = 28.0;
    final Paint cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final double l = scanRect.left;
    final double r = scanRect.right;
    final double t = scanRect.top;
    final double b = scanRect.bottom;
    final double rad = borderRadius;

    // Top-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(l, t + rad + cornerLength)
        ..lineTo(l, t + rad)
        ..arcToPoint(Offset(l + rad, t), radius: Radius.circular(rad))
        ..lineTo(l + rad + cornerLength, t),
      cornerPaint,
    );

    // Top-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(r - rad - cornerLength, t)
        ..lineTo(r - rad, t)
        ..arcToPoint(Offset(r, t + rad), radius: Radius.circular(rad))
        ..lineTo(r, t + rad + cornerLength),
      cornerPaint,
    );

    // Bottom-Right corner
    canvas.drawPath(
      Path()
        ..moveTo(r, b - rad - cornerLength)
        ..lineTo(r, b - rad)
        ..arcToPoint(Offset(r - rad, b), radius: Radius.circular(rad))
        ..lineTo(r - rad - cornerLength, b),
      cornerPaint,
    );

    // Bottom-Left corner
    canvas.drawPath(
      Path()
        ..moveTo(l + rad + cornerLength, b)
        ..lineTo(l + rad, b)
        ..arcToPoint(Offset(l, b - rad), radius: Radius.circular(rad))
        ..lineTo(l, b - rad - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindowSize != scanWindowSize ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.overlayColor != overlayColor;
  }
}
