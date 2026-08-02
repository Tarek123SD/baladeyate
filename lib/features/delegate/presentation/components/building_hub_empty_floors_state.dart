import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubEmptyFloorsState extends StatelessWidget {
  const BuildingHubEmptyFloorsState({
    super.key,
    required this.onAddFloor,
  });

  final VoidCallback onAddFloor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 28.h(context),
        horizontal: 16.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.layers,
            size: 34.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 10.h(context)),
          Text(
            'لا توجد طوابق بعد',
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'أضف أول طابق لتسجيل الشقق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 12.h(context)),
          FilledButton.icon(
            onPressed: onAddFloor,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة طابق'),
          ),
        ],
      ),
    );
  }
}
