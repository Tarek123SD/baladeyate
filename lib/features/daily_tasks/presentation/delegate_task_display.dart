import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    _ => 'مُسند',
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

/// Human-friendly survey title (avoids bare "مسح جديد" when possible).
String friendlyTitleForPin(SurveyPin pin) {
  final title = pin.title?.trim();
  if (title != null && title.isNotEmpty && title != 'مسح جديد') {
    return title;
  }
  final address = pin.address?.trim();
  if (address != null && address.isNotEmpty) {
    return address;
  }
  if (pin.buildingId != null) {
    return 'مبنى #${pin.buildingId}';
  }
  return 'مسح ميداني';
}

/// Prefer a readable address over raw coordinates.
String friendlyLocationForPin(SurveyPin pin) {
  final address = pin.address?.trim();
  if (address != null && address.isNotEmpty) {
    return address;
  }
  return 'موقع على الخريطة';
}

String? distanceLabelForPin(SurveyPin pin, LatLng? from) {
  if (from == null) return null;
  final meters = Geolocator.distanceBetween(
    from.latitude,
    from.longitude,
    pin.latitude,
    pin.longitude,
  );
  if (meters.isNaN) return null;
  if (meters < 1000) return '${meters.round()} م';
  return '${(meters / 1000).toStringAsFixed(1)} كم';
}

List<DelegateTask> activeDelegateTasks(List<DelegateTask> tasks) {
  return tasks
      .where((task) => !task.isCompleted)
      .toList(growable: false);
}

List<DelegateTask> completedDelegateTasks(List<DelegateTask> tasks) {
  return tasks.where((task) => task.isCompleted).toList(growable: false);
}
