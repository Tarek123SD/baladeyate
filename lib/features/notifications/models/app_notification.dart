class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String type;
  final Map<String, dynamic> data;
  final String? readAt;
  final String? createdAt;

  bool get isRead => readAt != null && readAt!.isNotEmpty;

  AppNotification copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    String? readAt,
    String? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get title {
    final title = data['title'];
    if (title is String && title.isNotEmpty) {
      return title;
    }

    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message.split('\n').first;
    }

    return _typeLabelAr(type);
  }

  String get message {
    final body = data['body'] ?? data['message'];
    if (body is String && body.isNotEmpty) {
      return body;
    }
    return '';
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      data: dataRaw is Map<String, dynamic> ? dataRaw : const {},
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static String _typeLabelAr(String type) {
    switch (type) {
      case 'ComplaintStatusUpdatedNotification':
        return 'تحديث حالة الشكوى';
      case 'NewTaskAssignedNotification':
        return 'مهمة ميدانية جديدة';
      case 'CitizenGeneralNotification':
        return 'إشعار عام';
      default:
        return 'إشعار';
    }
  }
}
