import 'package:flutter/material.dart';

/// Defines the possible execution statuses for a municipal transaction.
enum TransactionStatus {
  processing, // قيد المعالجة (Blue)
  inspection, // كشف ميداني (Orange)
  approved,   // مقبول / تم الإصدار (Green)
  rejected,   // مرفوض (Red)
}

/// Represents a municipal transaction / license application item.
class Transaction {
  final String id;
  final String transactionNumber;
  final String type;
  final TransactionStatus status;
  final String statusLabel;
  final String date;
  final List<String> metadataChips;
  final String? details;

  const Transaction({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.statusLabel,
    required this.date,
    this.metadataChips = const [],
    this.details,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'processing';
    TransactionStatus parsedStatus;
    switch (statusStr) {
      case 'inspection':
      case 'field_inspection':
      case 'kashf':
        parsedStatus = TransactionStatus.inspection;
        break;
      case 'approved':
      case 'completed':
        parsedStatus = TransactionStatus.approved;
        break;
      case 'rejected':
        parsedStatus = TransactionStatus.rejected;
        break;
      case 'processing':
      default:
        parsedStatus = TransactionStatus.processing;
        break;
    }

    return Transaction(
      id: json['id']?.toString() ?? '',
      transactionNumber: json['transaction_number'] as String? ?? 'TR-2026-000',
      type: json['type'] as String? ?? 'معاملة بلدية',
      status: parsedStatus,
      statusLabel: json['status_label'] as String? ?? _defaultStatusLabel(parsedStatus),
      date: json['date'] as String? ?? '22 يوليو 2026',
      metadataChips: json['metadata_chips'] != null
          ? List<String>.from(json['metadata_chips'] as List)
          : const [],
      details: json['details'] as String?,
    );
  }

  static String _defaultStatusLabel(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.processing:
        return 'قيد المعالجة';
      case TransactionStatus.inspection:
        return 'كشف ميداني';
      case TransactionStatus.approved:
        return 'تمت الموافقة';
      case TransactionStatus.rejected:
        return 'مرفوضة';
    }
  }

  // --- Visual Styling Helpers ---

  /// Soft tint color for badge background
  Color get statusBgColor {
    switch (status) {
      case TransactionStatus.processing:
        return const Color(0xFFE3F2FD); // Soft Blue
      case TransactionStatus.inspection:
        return const Color(0xFFFFF3E0); // Soft Orange
      case TransactionStatus.approved:
        return const Color(0xFFE8F5E9); // Soft Green
      case TransactionStatus.rejected:
        return const Color(0xFFFFEBEE); // Soft Red
    }
  }

  /// High-contrast primary color for status text and icons
  Color get statusFgColor {
    switch (status) {
      case TransactionStatus.processing:
        return const Color(0xFF1976D2); // Blue
      case TransactionStatus.inspection:
        return const Color(0xFFE65100); // Orange
      case TransactionStatus.approved:
        return const Color(0xFF2E7D32); // Green
      case TransactionStatus.rejected:
        return const Color(0xFFC62828); // Red
    }
  }

  /// Badge icon representation
  IconData get statusIcon {
    switch (status) {
      case TransactionStatus.processing:
        return Icons.sync_rounded;
      case TransactionStatus.inspection:
        return Icons.fact_check_outlined;
      case TransactionStatus.approved:
        return Icons.check_circle_rounded;
      case TransactionStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}
