import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum DailyTaskStatus { highPriority, scheduled, completed }

class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    required this.location,
    required this.distance,
    required this.time,
    required this.status,
    required this.position,
    this.delegateTaskId,
  });

  final String id;
  final String title;
  final String location;
  final String distance;
  final String time;
  final DailyTaskStatus status;
  final LatLng position;
  final int? delegateTaskId;

  bool get isCompleted => status == DailyTaskStatus.completed;
  bool get isActive => status == DailyTaskStatus.highPriority;

  factory DailyTask.fromDelegateTask(DelegateTask task, int index) {
    const base = LatLng(33.5138, 36.2765);
    final position = LatLng(
      base.latitude + (index * 0.004),
      base.longitude + (index * 0.003),
    );

    final status = switch (task.status) {
      'in_progress' => DailyTaskStatus.highPriority,
      'completed' || 'resolved' => DailyTaskStatus.completed,
      _ => DailyTaskStatus.scheduled,
    };

    return DailyTask(
      id: 'task-${task.id}',
      delegateTaskId: task.id,
      title: task.title,
      location: task.description?.trim().isNotEmpty == true
          ? task.description!.trim()
          : 'مهمة ميدانية',
      distance: '—',
      time: task.dueDate ?? '—',
      status: status,
      position: position,
    );
  }
}
