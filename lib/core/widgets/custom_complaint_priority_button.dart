import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintPriorityButton extends StatelessWidget {
  const CustomComplaintPriorityButton({
    super.key,
    required this.text,
    required this.isActive,
    this.onTap,
  });

  final String text;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r(context)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 14.s(context)),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.green
                : Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(12.r(context)),
            border: Border.all(
              color: isActive
                  ? AppColors.green
                  : AppColors.secondaryCharcoal.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.f(context),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : AppColors.secondaryCharcoal.withValues(alpha: 0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
