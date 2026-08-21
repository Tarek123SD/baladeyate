import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:flutter/material.dart';

class Complaint {
  const Complaint({
    required this.id,
    required this.description,
    required this.priority,
    required this.status,
    this.statusLabel,
    this.aiCategory,
    this.createdAt,
    this.attachments = const [],
    this.department,
    this.departmentLabel,
    this.latitude,
    this.longitude,
    this.assignedToField = false,
    this.fieldNotes,
    this.fieldOutcome,
    this.fieldOutcomeLabel,
    this.fieldAttachments = const [],
    this.fieldReportedAt,
    this.citizenName,
    this.citizenPhone,
  });

  final int id;
  final String description;
  final String priority;
  final String status;
  final String? statusLabel;
  final String? aiCategory;
  final String? createdAt;
  final List<String> attachments;
  final String? department;
  final String? departmentLabel;
  final double? latitude;
  final double? longitude;
  final bool assignedToField;
  final String? fieldNotes;
  final String? fieldOutcome;
  final String? fieldOutcomeLabel;
  final List<String> fieldAttachments;
  final String? fieldReportedAt;
  final String? citizenName;
  final String? citizenPhone;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    final attachments = <String>[];
    if (rawAttachments is List) {
      for (final item in rawAttachments) {
        if (item is String && item.isNotEmpty) {
          attachments.add(item);
        }
      }
    }

    final rawFieldAttachments = json['field_attachments'];
    final fieldAttachments = <String>[];
    if (rawFieldAttachments is List) {
      for (final item in rawFieldAttachments) {
        if (item is String && item.isNotEmpty) {
          fieldAttachments.add(item);
        }
      }
    }

    final userJson = json['user'];
    String? citizenName;
    String? citizenPhone;
    if (userJson is Map<String, dynamic>) {
      citizenName = userJson['name'] as String?;
      citizenPhone = userJson['phone_number'] as String? ??
          userJson['phone'] as String?;
    }

    return Complaint(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      aiCategory: json['ai_category'] as String?,
      createdAt: json['created_at'] as String?,
      attachments: attachments,
      department: json['department'] as String?,
      departmentLabel: json['department_label'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      assignedToField: json['assigned_to_field'] == true,
      fieldNotes: json['field_notes'] as String?,
      fieldOutcome: json['field_outcome'] as String?,
      fieldOutcomeLabel: json['field_outcome_label'] as String?,
      fieldAttachments: fieldAttachments,
      fieldReportedAt: json['field_reported_at'] as String?,
      citizenName: citizenName,
      citizenPhone: citizenPhone,
    );
  }

  bool get isPending => status == 'pending' || status == 'in_progress';

  bool get isResolved => status == 'resolved';

  ComplaintDescriptionParts get _parts => parseComplaintDescription(description);

  String get citizenMessage {
    final subject = _parts.subject.trim();
    final details = _parts.details.trim();
    if (subject.isEmpty) {
      return details;
    }
    if (details.isEmpty) {
      return subject;
    }
    return '$subject\n$details';
  }

  ({double latitude, double longitude})? get mapCoordinates {
    if (latitude != null && longitude != null) {
      return coordinatesFromLine(
            'الموقع: ${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
          ) ??
          (latitude: latitude!, longitude: longitude!);
    }
    return coordinatesFromLine(_parts.locationLine) ??
        coordinatesFromLine(description);
  }

  List<String> get imageAttachments => attachments
      .where(_looksLikeImage)
      .toList(growable: false);

  List<String> get fileAttachments => attachments
      .where((url) => !_looksLikeImage(url))
      .toList(growable: false);

  static bool _looksLikeImage(String url) {
    final path = url.split('?').first.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp') ||
        path.endsWith('.gif') ||
        path.endsWith('.bmp') ||
        !path.contains('.');
  }

  String get displayTitle {
    final subject = _parts.subject.trim();
    if (subject.isEmpty) {
      return aiCategory ?? 'شكوى بدون موضوع';
    }

    if (subject.length <= 60) {
      return subject;
    }

    return '${subject.substring(0, 57)}...';
  }

  String? get cardDetails {
    final details = _parts.details.trim();
    return details.isEmpty ? null : details;
  }

  String? get cardLocationDisplay => locationDisplayFromParts(_parts);

  Map<String, dynamic> toTrackCardMap() {
    return {
      'statusLabel': statusText,
      'statusColor': statusBackground,
      'statusFgColor': statusForeground,
      'statusIcon': statusIcon,
      'icon': Icons.report_outlined,
      'title': displayTitle,
      'date': _formatDate(),
      'request': '#$id',
      if (cardDetails != null) 'details': cardDetails,
      if (cardLocationDisplay != null) 'locationAddress': cardLocationDisplay,
      'category':
          (aiCategory != null && aiCategory!.isNotEmpty) ? aiCategory! : null,
      'priorityLabel': priorityText,
      'priorityColor': priorityColor,
      'tags': [
        if (aiCategory != null && aiCategory!.isNotEmpty) aiCategory!,
        priorityText,
      ],
    };
  }

  // ---- Status visuals (shared across card & detail sheet) ----

  String get statusText => statusLabel ?? _statusLabelAr(status);

  Color get statusBackground => _statusBackground(status);

  Color get statusForeground => _statusForeground(status);

  IconData get statusIcon => _statusIcon(status);

  String get priorityText => _priorityLabelAr(priority);

  Color get priorityColor => _priorityColor(priority);

  static String _statusLabelAr(String status) {
    switch (status) {
      case 'in_progress':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل بنجاح';
      case 'rejected':
        return 'مرفوضة';
      case 'pending':
      default:
        return 'قيد المراجعة';
    }
  }

  static Color _statusBackground(String status) {
    switch (status) {
      case 'resolved':
        return const Color(0xFFDCEFE4);
      case 'rejected':
        return const Color(0xFFF3E2E5);
      case 'in_progress':
        return const Color(0xFFDFEEF5);
      case 'pending':
      default:
        return const Color(0xFFF5EDD8);
    }
  }

  static Color _statusForeground(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.green;
      case 'rejected':
        return AppColors.thirdDeepUmber;
      case 'in_progress':
        return AppColors.thirdForest;
      case 'pending':
      default:
        return AppColors.primaryGoldenWheat;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'resolved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  static String _priorityLabelAr(String priority) {
    switch (priority) {
      case 'urgent':
        return 'طارئ';
      case 'high':
        return 'عالي';
      default:
        return 'اعتيادي';
    }
  }

  static Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFC62828);
      case 'high':
        return const Color(0xFFB26A00);
      default:
        return const Color(0xFF1B7B3A);
    }
  }

  String get formattedDate => _formatDate();

  String _formatDate() {
    if (createdAt == null || createdAt!.isEmpty) {
      return 'تاريخ غير متوفر';
    }

    final parsed = DateTime.tryParse(createdAt!);
    if (parsed == null) {
      return 'تم تقديمها في $createdAt';
    }

    return 'تم تقديمها في ${parsed.day}/${parsed.month}/${parsed.year}';
  }
}
