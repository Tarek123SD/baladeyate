import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationSectionHeader extends StatelessWidget {
  const DonationSectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w(context),
          height: 18.h(context),
          decoration: BoxDecoration(
            color: AppColors.primaryForest,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 6.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontSize: 12.5.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w(context)),
              Icon(
                Icons.chevron_left_rounded,
                size: 18.ic(context),
                color: AppColors.primaryForest,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
