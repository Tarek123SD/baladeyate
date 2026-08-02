import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubCompletedBanner extends StatelessWidget {
  const BuildingHubCompletedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.thirdForest.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(
          color: AppColors.thirdForest.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            AppIcons.statsDone,
            color: AppColors.thirdForest,
            size: 20.ic(context),
          ),
          SizedBox(width: 8.w(context)),
          Text(
            'المسح مكتمل',
            style: TextStyle(
              color: AppColors.thirdForest,
              fontSize: 14.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
