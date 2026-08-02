import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingsNoResultsState extends StatelessWidget {
  const BuildingsNoResultsState({
    super.key,
    required this.onClearFilters,
  });

  final VoidCallback onClearFilters;

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
      ),
      child: Column(
        children: [
          Text(
            'لا نتائج مطابقة',
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          TextButton(
            onPressed: onClearFilters,
            child: Text(
              'مسح الفلاتر',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
