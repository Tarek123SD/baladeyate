import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
          textDirection: TextDirection.rtl,
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryForest,
                    fontWeight: FontWeight.w600,
                  ),
              textDirection: TextDirection.rtl,
            ),
          )
        else
          Container(
            width: 60.s(context),
            height: 3.s(context),
            color: AppColors.secondaryForest,
          ),
      ],
    );
  }
}
