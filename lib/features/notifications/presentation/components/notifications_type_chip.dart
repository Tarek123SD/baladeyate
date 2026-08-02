import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsTypeChip extends StatelessWidget {
  const NotificationsTypeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.thirdForest.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 7.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.thirdForest.withValues(alpha: 0.45)
                  : AppColors.primaryForest.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.secondaryCharcoal.withValues(alpha: 0.8),
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
