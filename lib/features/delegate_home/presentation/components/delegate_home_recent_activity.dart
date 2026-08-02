import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_task_display.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/features/home/presentation/components/update_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeRecentActivity extends StatelessWidget {
  const DelegateHomeRecentActivity({super.key, required this.state});

  final DailyTasksState state;

  @override
  Widget build(BuildContext context) {
    final completedTasks = completedDelegateTasks(state.delegateTasks).take(1);
    final completed = state.pins
        .where((pin) => pin.status == SurveyPinStatus.completed)
        .take(2 - completedTasks.length)
        .toList();

    if (completedTasks.isEmpty && completed.isEmpty) {
      return UpdateCard(
        title: 'لا يوجد نشاط مكتمل بعد',
        time: 'اليوم',
        description:
            'ستظهر هنا المهام المكتملة بعد إنهاء المسوحات الميدانية.',
        icon: AppIcons.transactions,
        iconBgColor: AppColors.primaryForest,
      );
    }

    return Column(
      children: [
        for (final task in completedTasks)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h(context)),
            child: UpdateCard(
              title: 'اكتملت مهمة: ${task.title}',
              time: 'مكتمل',
              description: locationLabelForDelegateTask(task),
              icon: AppIcons.statsDone,
              iconBgColor: AppColors.primaryForest,
            ),
          ),
        for (final pin in completed)
          Padding(
            padding: EdgeInsets.only(bottom: 12.h(context)),
            child: UpdateCard(
              title: 'اكتمل مسح: ${friendlyTitleForPin(pin)}',
              time: 'مكتمل',
              description: friendlyLocationForPin(pin),
              icon: AppIcons.statsDone,
              iconBgColor: AppColors.primaryForest,
            ),
          ),
      ],
    );
  }
}
