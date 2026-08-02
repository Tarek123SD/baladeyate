import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TasksStatsHeader extends StatelessWidget {
  const TasksStatsHeader({
    super.key,
    required this.state,
  });

  final DailyTasksState state;

  @override
  Widget build(BuildContext context) {
    final progress = state.achievementRatio;
    final assignedCount = state.pins
        .where((p) => p.status == SurveyPinStatus.assigned)
        .length;
    final inProgressCount = state.pins
        .where((p) => p.status == SurveyPinStatus.inProgress)
        .length;
    final completedCount = state.pins
        .where((p) => p.status == SurveyPinStatus.completed)
        .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'مركز المهام الميدانية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${state.completedTasks}/${state.totalTasks}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r(context)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h(context),
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              color: AppColors.thirdGoldenWheat,
            ),
          ),
          SizedBox(height: 12.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              TasksStatPill(label: 'مُسند', value: '$assignedCount'),
              SizedBox(width: 8.w(context)),
              TasksStatPill(label: 'قيد الإدخال', value: '$inProgressCount'),
              SizedBox(width: 8.w(context)),
              TasksStatPill(label: 'مكتمل', value: '$completedCount'),
            ],
          ),
        ],
      ),
    );
  }
}

class TasksStatPill extends StatelessWidget {
  const TasksStatPill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12.r(context)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
