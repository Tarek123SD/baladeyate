import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DigitalDocumentsErrorState extends StatelessWidget {
  const DigitalDocumentsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 44.ic(context),
          color: AppColors.alertRed,
        ),
        SizedBox(height: 12.h(context)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5.f(context),
            color: AppColors.primaryCharcoal,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          label: const Text(
            'إعادة المحاولة',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
          ),
        ),
      ],
    );
  }
}
