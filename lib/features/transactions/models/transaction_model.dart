/// Model representing a municipal transaction / license application.
class TransactionModel {
  final int id;
  final String transactionNumber;
  final String type;
  final String status;
  final String createdAt;
  final Map<String, dynamic>? formData;

  const TransactionModel({
    required this.id,
    required this.transactionNumber,
    required this.type,
    required this.status,
    required this.createdAt,
    this.formData,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
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
      if (formData != null) 'form_data': formData,
    };
  }
}
