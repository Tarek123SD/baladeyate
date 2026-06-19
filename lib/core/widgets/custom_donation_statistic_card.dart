import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationStatisticCard extends StatelessWidget {
  const CustomDonationStatisticCard({
    super.key,
    required this.width,
    required this.value,
    required this.label,
  });

  final double width;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 22.h(context),
          horizontal: 16.w(context),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryCharcoal, width: 0.3),
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 24.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h(context)),
            Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: const Color(0xFF7A7A7A),
                fontSize: 13.f(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
