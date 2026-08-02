import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:flutter/material.dart';

/// Colored rectangle marker for a single grave on the cemetery map.
class GraveMarker extends StatelessWidget {
  const GraveMarker({
    super.key,
    required this.grave,
    this.onTap,
  });

  final GraveModel grave;
  final VoidCallback? onTap;

  Color get _fillColor {
    return switch (grave.status) {
      'available' => Colors.green.withValues(alpha: 0.4),
      'occupied' => const Color(0xFF8B1A1A).withValues(alpha: 0.55),
      'booked' => const Color(0xFF8B1A1A).withValues(alpha: 0.7),
      _ => Colors.grey.withValues(alpha: 0.4),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: grave.width,
        height: grave.height,
        decoration: BoxDecoration(
          color: _fillColor,
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }
}
