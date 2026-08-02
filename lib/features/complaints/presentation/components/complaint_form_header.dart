import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintFormHeader extends StatelessWidget {
  const ComplaintFormHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'تقديم شكوى رسمية',
          style: TextStyle(
            fontSize: 22.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
        ),
        SizedBox(height: 6.s(context)),
        Text(
          'ساعدنا في تحسين الخدمات عبر مشاركة التفاصيل بدقة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.f(context),
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}
