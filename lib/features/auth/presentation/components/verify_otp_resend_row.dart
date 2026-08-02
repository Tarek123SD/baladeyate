import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class VerifyOtpResendRow extends StatelessWidget {
  const VerifyOtpResendRow({
    super.key,
    required this.canResend,
    required this.secondsRemaining,
    required this.onResend,
  });

  final bool canResend;
  final int secondsRemaining;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: canResend
          ? TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.secondaryForest,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.f(context),
                ),
              ),
              child: const Text('إعادة إرسال الرمز'),
            )
          : Text(
              'إعادة إرسال الرمز خلال $secondsRemaining ثانية',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14.f(context),
              ),
            ),
    );
  }
}
