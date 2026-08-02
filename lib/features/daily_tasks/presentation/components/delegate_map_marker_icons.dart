import 'dart:ui' as ui;

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Cached custom map pin / cluster bitmaps for the delegate survey map.
class DelegateMapMarkerIcons {
  DelegateMapMarkerIcons._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static Color colorForStatus(SurveyPinStatus status) {
    switch (status) {
      case SurveyPinStatus.assigned:
        return const Color(0xFFE53935);
      case SurveyPinStatus.inProgress:
        return const Color(0xFFF57C00);
      case SurveyPinStatus.completed:
        return AppColors.thirdForest;
    }
  }

  static Future<BitmapDescriptor> forStatus(
    SurveyPinStatus status, {
    bool selected = false,
  }) {
    final key = 'pin-${status.name}-$selected';
    final cached = _cache[key];
    if (cached != null) return SynchronousFuture(cached);
    return _paintPin(
      color: colorForStatus(status),
      selected: selected,
    ).then((icon) {
      _cache[key] = icon;
      return icon;
    });
  }

  static Future<BitmapDescriptor> cluster(int count) {
    final key = 'cluster-$count';
    final cached = _cache[key];
    if (cached != null) return SynchronousFuture(cached);
    return _paintCluster(count).then((icon) {
      _cache[key] = icon;
      return icon;
    });
  }

  static Future<BitmapDescriptor> _paintPin({
    required Color color,
    required bool selected,
  }) async {
    final double logical = selected ? 48 : 40;
    final double dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final int size = (logical * dpr).round().clamp(64, 160);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final centerX = size / 2;
    final radius = size * 0.28;
    final circleCenter = Offset(centerX, size * 0.36);

    final path = Path()
      ..moveTo(centerX, size * 0.92)
      ..quadraticBezierTo(
        size * 0.18,
        size * 0.62,
        circleCenter.dx - radius * 0.85,
        circleCenter.dy + radius * 0.2,
      )
      ..arcToPoint(
        Offset(circleCenter.dx + radius * 0.85, circleCenter.dy + radius * 0.2),
        radius: Radius.circular(radius * 1.15),
        clockwise: true,
      )
      ..quadraticBezierTo(size * 0.82, size * 0.62, centerX, size * 0.92)
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.04);
    canvas.drawPath(path.shift(Offset(0, size * 0.03)), shadowPaint);

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // Inner white ring for contrast on satellite imagery.
    canvas.drawCircle(
      circleCenter,
      radius * 0.78,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      circleCenter,
      radius * 0.52,
      Paint()..color = color,
    );

    if (selected) {
      canvas.drawCircle(
        circleCenter,
        radius * 1.35,
        Paint()
          ..color = color.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = size * 0.05,
      );
    }

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
      width: logical,
      height: logical,
    );
  }

  static Future<BitmapDescriptor> _paintCluster(int count) async {
    const double logical = 48;
    final double dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final int size = (logical * dpr).round().clamp(72, 160);
    final label = count > 99 ? '99+' : '$count';

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    canvas.drawCircle(
      center.translate(0, size * 0.04),
      size * 0.42,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.05),
    );
    canvas.drawCircle(center, size * 0.42, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      size * 0.36,
      Paint()..color = AppColors.primaryForest,
    );

    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * (label.length > 2 ? 0.28 : 0.34),
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );

    final image = await recorder.endRecording().toImage(size, size);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
      width: logical,
      height: logical,
    );
  }
}
