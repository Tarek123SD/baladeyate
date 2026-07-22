import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FilePickerContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const FilePickerContainer({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: primaryColor,
          strokeWidth: 1.5,
          gap: 6,
          radius: 12.r(context),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 24.h(context),
            horizontal: 16.w(context),
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 36.s(context),
                color: primaryColor,
              ),
              SizedBox(height: 12.h(context)),
              Text(
                label,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.s(context),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 6.h(context)),
              Text(
                'الحد الأقصى لحجم الملف 5 ميجابايت (PDF, JPG, PNG)',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.s(context),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.gap = 5.0,
    this.radius = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashedPath = _buildDashedPath(path, strokeWidth * 3, gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _buildDashedPath(Path source, double dashWidth, double dashGap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}
