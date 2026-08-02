import 'package:flutter/material.dart';

/// Dimmed loading overlay shown while graves load or a create request runs.
class CemeteryMapLoadingOverlay extends StatelessWidget {
  const CemeteryMapLoadingOverlay({
    super.key,
    required this.showLoadingMessage,
  });

  final bool showLoadingMessage;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0x33000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            if (showLoadingMessage) ...[
              const SizedBox(height: 12),
              Text(
                'جاري تحميل القبور...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
