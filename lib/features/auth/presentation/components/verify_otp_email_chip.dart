import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class VerifyOtpEmailChip extends StatelessWidget {
  const VerifyOtpEmailChip({
    super.key,
    required this.email,
  });

  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 10.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryForest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: AppColors.secondaryForest.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.email_outlined,
            size: 16.s(context),
            color: AppColors.secondaryForest,
          ),
          SizedBox(width: 8.w(context)),
          Text(
            email,
            style: TextStyle(
              color: AppColors.secondaryForest,
              fontWeight: FontWeight.w600,
              fontSize: 13.f(context),
            ),
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}
