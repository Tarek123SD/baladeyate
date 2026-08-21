import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_task_display.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

Future<void> showDelegateAssignedTaskSheet(
  BuildContext context,
  DelegateTask task,
) {
  final cubit = context.read<DailyTasksCubit>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: cubit,
        child: _DelegateAssignedTaskSheet(task: task),
      );
    },
  );
}

class _DelegateAssignedTaskSheet extends StatelessWidget {
  const _DelegateAssignedTaskSheet({required this.task});

  final DelegateTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w(context),
        8.h(context),
        20.w(context),
        24.h(context) + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            task.title,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 10.h(context)),
          Text(
            locationLabelForDelegateTask(task),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
              fontSize: 14.f(context),
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'الحالة: ${statusLabelForDelegateTask(task)}',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
              fontSize: 13.f(context),
            ),
          ),
          if (task.dueDate?.isNotEmpty == true) ...[
            SizedBox(height: 8.h(context)),
            Text(
              'تاريخ الاستحقاق: ${task.dueDate}',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                fontSize: 13.f(context),
              ),
            ),
          ],
          if (!task.isCompleted) ...[
            SizedBox(height: 20.h(context)),
            if (!task.isInProgress)
              _ActionButton(
                label: 'بدء المهمة',
                color: AppColors.green,
                onPressed: () => _updateStatus(context, 'in_progress'),
              ),
            if (task.isInProgress) ...[
              _ActionButton(
                label: 'إكمال المهمة',
                color: AppColors.green,
                onPressed: () => _updateStatus(context, 'completed'),
              ),
              SizedBox(height: 10.h(context)),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    final cubit = context.read<DailyTasksCubit>();
    final success = await cubit.updateTaskStatus(id: task.id, status: status);
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة المهمة')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحديث حالة المهمة')),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h(context),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
