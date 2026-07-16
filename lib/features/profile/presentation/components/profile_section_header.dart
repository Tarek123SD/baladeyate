import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader({
    super.key,
    required this.title,
    this.badge,
  });

  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 5.w(context),
          height: 20.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
          textDirection: TextDirection.rtl,
        ),
        if (badge != null) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 5.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryForest.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20.r(context)),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryForest,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ],
    );
  }
}
