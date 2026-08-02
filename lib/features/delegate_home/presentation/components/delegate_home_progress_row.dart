import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeProgressRow extends StatelessWidget {
  const DelegateHomeProgressRow({super.key, required this.state});

  final DailyTasksState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            CustomTrackStatisticCard(
              title: 'إجمالي المهام',
              value: '${state.totalTasks}',
              backgroundColor: Colors.white,
              textColor: AppColors.primaryForest,
            ),
            SizedBox(width: 10.w(context)),
            CustomTrackStatisticCard(
              title: 'قيد التنفيذ',
              value: '${state.inProgressTasks}',
              backgroundColor:
                  AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
              textColor: AppColors.primaryForest,
            ),
          ],
        ),
        SizedBox(height: 10.h(context)),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            CustomTrackStatisticCard(
              title: 'مكتملة',
              value: '${state.completedTasks}',
              backgroundColor:
                  AppColors.secondaryForest.withValues(alpha: 0.15),
              textColor: AppColors.primaryForest,
            ),
            SizedBox(width: 10.w(context)),
            CustomTrackStatisticCard(
              title: 'الإنجاز',
              value: '${state.achievementPercent}%',
              backgroundColor:
                  AppColors.thirdGoldenWheat.withValues(alpha: 0.75),
              textColor: AppColors.primaryGoldenWheat,
            ),
          ],
        ),
      ],
    );
  }
}
