import 'dart:convert';

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

  /// Laravel may send `App\Notifications\FooNotification`; FCM may send slugs.
  String get normalizedType => canonicalNotificationType(type);

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
    final data = _asStringKeyMap(json['data']);
    return AppNotification(
      id: json['id']?.toString() ?? json['notification_id']?.toString() ?? '',
      type: json['type']?.toString() ??
          json['notification_type']?.toString() ??
          data['type']?.toString() ??
          '',
      data: data,
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// Builds a notification from an FCM data payload (all values are strings).
  factory AppNotification.fromFcmData(Map<String, dynamic> payload) {
    final merged = _asStringKeyMap(payload);
    final nested = _asStringKeyMap(payload['data']);
    if (nested.isNotEmpty) {
      merged.addAll(nested);
    }
    return AppNotification(
      id: merged['notification_id']?.toString() ??
          merged['id']?.toString() ??
          '',
      type: merged['type']?.toString() ??
          merged['notification_type']?.toString() ??
          '',
      data: merged,
    );
  }

  static Map<String, dynamic> _asStringKeyMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        return _asStringKeyMap(decoded);
      } catch (_) {
        return <String, dynamic>{};
      }
    }
    return <String, dynamic>{};
  }

  static String _typeLabelAr(String type) {
    switch (canonicalNotificationType(type)) {
      case 'ComplaintStatusUpdatedNotification':
        return 'تحديث حالة الشكوى';
      case 'NewTaskAssignedNotification':
        return 'مهمة ميدانية جديدة';
      case 'CitizenGeneralNotification':
        return 'إشعار عام';
      case 'IdentityVerificationNotification':
        return 'توثيق الحساب';
      case 'TransactionStatusUpdatedNotification':
        return 'تحديث حالة المعاملة';
      case 'BulkNotification':
        return 'إشعار جماعي';
      default:
        return 'إشعار';
    }
  }
}

/// Strips Laravel namespaces and maps FCM slugs onto known notification classes.
String canonicalNotificationType(String type) {
  final trimmed = type.trim();
  if (trimmed.isEmpty) return trimmed;

  final shortName = trimmed.split(RegExp(r'[\\/.]')).last;
  switch (shortName) {
    case 'ComplaintStatusUpdatedNotification':
    case 'NewTaskAssignedNotification':
    case 'CitizenGeneralNotification':
    case 'IdentityVerificationNotification':
    case 'TransactionStatusUpdatedNotification':
    case 'BulkNotification':
    case 'GraveReservationStatusUpdatedNotification':
      return shortName;
  }

  final compact = shortName.toLowerCase().replaceAll(RegExp(r'[_-\s]'), '');
  if (compact.contains('complaint')) {
    return 'ComplaintStatusUpdatedNotification';
  }
  if (compact.contains('transaction')) {
    return 'TransactionStatusUpdatedNotification';
  }
  if (compact.contains('identity') ||
      compact.contains('verification') ||
      compact.contains('kyc')) {
    return 'IdentityVerificationNotification';
  }
  if (compact.contains('task')) {
    return 'NewTaskAssignedNotification';
  }
  if (compact.contains('bulk')) {
    return 'BulkNotification';
  }
  if (compact.contains('gravereservation') ||
      compact.contains('grave') && compact.contains('reservation')) {
    return 'GraveReservationStatusUpdatedNotification';
  }
  if (compact.contains('general') || compact.contains('announcement')) {
    return 'CitizenGeneralNotification';
  }
  return shortName;
}
