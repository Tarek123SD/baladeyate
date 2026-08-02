import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TasksStatusFilters extends StatelessWidget {
  const TasksStatusFilters({
    super.key,
    required this.state,
    required this.selected,
    required this.onSelected,
  });

  final DailyTasksState state;
  final SurveyPinStatus? selected;
  final ValueChanged<SurveyPinStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(SurveyPinStatus?, String, int)>[
      (null, 'الكل', state.pins.length),
      (
        SurveyPinStatus.assigned,
        'مُسند',
        state.pins.where((p) => p.status == SurveyPinStatus.assigned).length,
      ),
      (
        SurveyPinStatus.inProgress,
        'قيد الإدخال',
        state.pins
            .where((p) => p.status == SurveyPinStatus.inProgress)
            .length,
      ),
      (
        SurveyPinStatus.completed,
        'مكتملة',
        state.pins
            .where((p) => p.status == SurveyPinStatus.completed)
            .length,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (final option in options) ...[
            TasksFilterChip(
              label: '${option.$2} ${option.$3}',
              selected: selected == option.$1,
              onTap: () => onSelected(option.$1),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }
}

class TasksFilterChip extends StatelessWidget {
  const TasksFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryForest : Colors.white,
      borderRadius: BorderRadius.circular(20.r(context)),
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w(context),
            vertical: 9.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.primaryForest.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryForest,
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
