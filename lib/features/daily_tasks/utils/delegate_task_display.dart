import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';

DailyTaskStatus cardStatusForDelegateTask(DelegateTask task) {
  if (task.isCompleted) return DailyTaskStatus.completed;
  if (task.isInProgress) return DailyTaskStatus.highPriority;
  return DailyTaskStatus.scheduled;
}

String statusLabelForDelegateTask(DelegateTask task) {
  if (task.statusLabel?.isNotEmpty == true) {
    return task.statusLabel!;
  }

  return switch (task.status) {
    'pending' => 'في الانتظار',
    'in_progress' => 'قيد التنفيذ',
    'completed' || 'resolved' => 'مكتمل',
    _ => 'مهمة ميدانية',
  };
}

String locationLabelForDelegateTask(DelegateTask task) {
  final description = task.description?.trim();
  if (description != null && description.isNotEmpty) {
    return description;
  }
  return 'مهمة معيّنة من الإدارة';
}

String timeLabelForDelegateTask(DelegateTask task) {
  if (task.dueDate?.isNotEmpty == true) {
    return task.dueDate!;
  }
  if (task.createdAt?.isNotEmpty == true) {
    return task.createdAt!;
  }
  return '—';
}

List<DelegateTask> activeDelegateTasks(List<DelegateTask> tasks) {
  return tasks
      .where((task) => !task.isCompleted)
      .toList(growable: false);
}

List<DelegateTask> completedDelegateTasks(List<DelegateTask> tasks) {
  return tasks.where((task) => task.isCompleted).toList(growable: false);
}
