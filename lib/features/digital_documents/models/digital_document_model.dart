import 'dart:convert';

/// Model representing an approved digital document (municipal transaction).
class DigitalDocumentModel {
  final int id;
  final String transactionNumber;
  final String type;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? formData;

  const DigitalDocumentModel({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.formData,
  });

  factory DigitalDocumentModel.fromJson(Map<String, dynamic> json) {
    return DigitalDocumentModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      transactionNumber: json['transaction_number'] as String? ??
          json['transactionNumber'] as String? ??
          'TR-${json['id'] ?? 0}',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'approved',
      createdAt: json['created_at'] as String? ??
          json['createdAt'] as String? ??
          '',
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String?,
      formData: json['form_data'] is Map<String, dynamic>
          ? json['form_data'] as Map<String, dynamic>
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_number': transactionNumber,
      'type': type,
      'status': status,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (formData != null) 'form_data': formData,
    };
  }

  /// Date of approval or issuance (prefers updated_at, falls back to created_at)
  String get displayDate {
    final rawDate = (updatedAt != null && updatedAt!.isNotEmpty)
        ? updatedAt!
        : createdAt;
    if (rawDate.isEmpty) return 'تاريخ غير متوفر';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return '${parsed.year}/${parsed.month.toString().padLeft(2, '0')}/${parsed.day.toString().padLeft(2, '0')}';
  }

  /// Translated Arabic document type
  String get translatedType {
    switch (type.toLowerCase()) {
      case 'commercial_license':
        return 'رخصة تجارية';
      case 'building_permit':
        return 'رخصة بناء';
      case 'occupancy_certificate':
        return 'شهادة إشغال';
      case 'health_certificate':
        return 'شهادة صحية';
      case 'signage_permit':
        return 'رخصة لوحة إعلانية';
      default:
        if (type.trim().isNotEmpty) {
          return type;
        }
        return 'وثيقة رقمية معتمدة';
    }
  }

  /// Formatted JSON payload for QR code scan & inspection verification
  String get qrPayload {
    final payloadMap = {
      'id': id,
      'number': transactionNumber,
      'type': type.isNotEmpty ? type : 'license',
      'status': status,
    };
    return jsonEncode(payloadMap);
  }
}
