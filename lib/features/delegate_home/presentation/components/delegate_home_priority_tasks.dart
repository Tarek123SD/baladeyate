import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_assigned_task_sheet.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_widgets.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_task_display.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomePriorityTasks extends StatelessWidget {
  const DelegateHomePriorityTasks({super.key, required this.state});

  final DailyTasksState state;

  @override
  Widget build(BuildContext context) {
    final assignedTasks = state.activeAssignedTasks.take(2).toList();
    final priorityPins = state.pins
        .where(
          (pin) =>
              pin.status == SurveyPinStatus.assigned ||
              pin.status == SurveyPinStatus.inProgress,
        )
        .take(3 - assignedTasks.length)
        .toList();

    if (assignedTasks.isEmpty && priorityPins.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.s(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          'لا توجد مهام نشطة حالياً. ابدأ مسحاً جديداً من الخريطة.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
            fontSize: 14.f(context),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (final task in assignedTasks)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h(context)),
            child: CustomDailyTaskCard(
              title: task.title,
              location: locationLabelForDelegateTask(task),
              statusLabel: statusLabelForDelegateTask(task),
              metaLabel: timeLabelForDelegateTask(task),
              status: cardStatusForDelegateTask(task),
              isPriority: task.isInProgress,
              emphasized: true,
              startLabel:
                  task.isInProgress ? 'متابعة المهمة' : 'بدء المهمة',
              onTap: () => showDelegateAssignedTaskSheet(context, task),
              onStart: task.isInProgress
                  ? () => showDelegateAssignedTaskSheet(context, task)
                  : () => context.read<DailyTasksCubit>().updateTaskStatus(
                        id: task.id,
                        status: 'in_progress',
                      ),
            ),
          ),
        for (final pin in priorityPins)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h(context)),
            child: CustomDailyTaskCard(
              title: friendlyTitleForPin(pin),
              location: friendlyLocationForPin(pin),
              statusLabel: statusLabelForPin(pin),
              metaLabel: distanceLabelForPin(pin, state.currentPosition),
              status: cardStatusForPin(pin),
              startLabel: actionLabelForPin(pin),
              onTap: () => showPinInfoSheet(context, pin),
              onStart: pin.status == SurveyPinStatus.completed
                  ? null
                  : () => resumeDelegateSurvey(context, pin),
              onNavigate: () {
                context.read<DailyTasksCubit>().selectPin(pin.id);
                context.go('/delegate/map');
              },
            ),
          ),
      ],
    );
  }
}
