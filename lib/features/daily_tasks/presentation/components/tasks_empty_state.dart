import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TasksEmptyState extends StatelessWidget {
  const TasksEmptyState({
    super.key,
    required this.hasStatusFilter,
  });

  final bool hasStatusFilter;

  @override
  Widget build(BuildContext context) {
    final message = hasStatusFilter
        ? 'لا توجد مهام بهذه الحالة.'
        : 'لا توجد مهام ميدانية بعد.';
    final hint = hasStatusFilter
        ? 'جرّب تغيير الفلتر لعرض مهام أخرى.'
        : 'ابدأ مسحاً جديداً من تبويب الخريطة.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 36.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 40.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 14.h(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
