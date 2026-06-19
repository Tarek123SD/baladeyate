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
  });

  final int id;
  final String description;
  final String priority;
  final String status;
  final String? statusLabel;
  final String? aiCategory;
  final String? createdAt;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      statusLabel: json['status_label'] as String?,
      aiCategory: json['ai_category'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  bool get isPending => status == 'pending' || status == 'in_progress';

  bool get isResolved => status == 'resolved';

  String get displayTitle {
    final trimmed = description.trim();
    if (trimmed.isEmpty) {
      return aiCategory ?? 'شكوى بدون عنوان';
    }

    final firstLine = trimmed.split('\n').first.trim();
    if (firstLine.length <= 60) {
      return firstLine;
    }

    return '${firstLine.substring(0, 57)}...';
  }

  Map<String, dynamic> toTrackCardMap() {
    return {
      'statusLabel': statusLabel ?? _statusLabelAr(status),
      'statusColor': _statusColor(status),
      'icon': Icons.report_outlined,
      'title': displayTitle,
      'date': _formatDate(),
      'request': '#$id',
      'description': description,
      'tags': [
        if (aiCategory != null && aiCategory!.isNotEmpty) aiCategory!,
        _priorityLabelAr(priority),
      ],
    };
  }

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

  static Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return const Color(0xFFE2F5E8);
      case 'rejected':
        return const Color(0xFFFFE0E0);
      case 'in_progress':
        return const Color(0xFFFFF3CD);
      case 'pending':
      default:
        return const Color(0xFFFFB980);
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
