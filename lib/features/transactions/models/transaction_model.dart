/// Model representing a municipal transaction / license application.
class TransactionModel {
  final int id;
  final String transactionNumber;
  final String type;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final int? buildingId;
  final Map<String, dynamic>? formData;
  final List<String> attachments;
  final String? adminNotes;
  final String? inspectionNotes;
  final List<TransactionStatusHistoryItem> statusHistory;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.buildingId,
    this.formData,
    this.attachments = const [],
    this.adminNotes,
    this.inspectionNotes,
    this.statusHistory = const [],
  });

  bool get needsDocuments => status.toLowerCase() == 'needs_documents';

  bool get canCancel {
    final s = status.toLowerCase();
    return s == 'pending' || s == 'needs_documents';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachments'];
    final attachments = <String>[];
    if (rawAttachments is List) {
      for (final item in rawAttachments) {
        if (item is String && item.isNotEmpty) {
          attachments.add(item);
        }
      }
    }

    final rawHistory = json['status_history'] ?? json['statusHistory'];
    final history = <TransactionStatusHistoryItem>[];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map<String, dynamic>) {
          history.add(TransactionStatusHistoryItem.fromJson(item));
        }
      }
    }

    return TransactionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      transactionNumber: json['transaction_number'] as String? ??
          json['transactionNumber'] as String? ??
          'TR-${json['id'] ?? 0}',
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] as String? ??
          json['createdAt'] as String? ??
          '',
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String?,
      buildingId: json['building_id'] is int
          ? json['building_id'] as int
          : int.tryParse(json['building_id']?.toString() ?? ''),
      formData: json['form_data'] is Map<String, dynamic>
          ? json['form_data'] as Map<String, dynamic>
          : null,
      attachments: attachments,
      adminNotes: json['admin_notes'] as String? ?? json['adminNotes'] as String?,
      inspectionNotes:
          json['inspection_notes'] as String? ?? json['inspectionNotes'] as String?,
      statusHistory: history,
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
      if (buildingId != null) 'building_id': buildingId,
      if (formData != null) 'form_data': formData,
      'attachments': attachments,
      if (adminNotes != null) 'admin_notes': adminNotes,
      if (inspectionNotes != null) 'inspection_notes': inspectionNotes,
    };
  }
}

class TransactionStatusHistoryItem {
  final String? fromStatus;
  final String toStatus;
  final String? note;
  final int? changedBy;
  final String? createdAt;

  const TransactionStatusHistoryItem({
    required this.toStatus,
    this.fromStatus,
    this.note,
    this.changedBy,
    this.createdAt,
  });

  factory TransactionStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionStatusHistoryItem(
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String? ?? '',
      note: json['note'] as String?,
      changedBy: json['changed_by'] is int
          ? json['changed_by'] as int
          : int.tryParse(json['changed_by']?.toString() ?? ''),
      createdAt: json['created_at'] as String?,
    );
  }
}
