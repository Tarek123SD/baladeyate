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
  });

  final String id;
  final String title;
  final String location;
  final String distance;
  final String time;
  final DailyTaskStatus status;
  final LatLng position;

  bool get isCompleted => status == DailyTaskStatus.completed;
  bool get isActive => status == DailyTaskStatus.highPriority;
}
