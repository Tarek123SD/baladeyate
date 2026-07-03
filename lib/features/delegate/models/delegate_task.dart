class DelegateTask {
  const DelegateTask({
    required this.id,
    required this.title,
    this.description,
    this.status,
    this.statusLabel,
    this.dueDate,
    this.createdAt,
  });

  final int id;
  final String title;
  final String? description;
  final String? status;
  final String? statusLabel;
  final String? dueDate;
  final String? createdAt;

  bool get isCompleted => status == 'completed' || status == 'resolved';
  bool get isInProgress => status == 'in_progress';

  factory DelegateTask.fromJson(Map<String, dynamic> json) {
    return DelegateTask(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
      dueDate: json['due_date'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
