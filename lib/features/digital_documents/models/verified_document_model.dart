/// Model representing the response from document verification endpoint
/// POST /api/v1/delegate/verify-document
class VerifiedDocumentModel {
  final int? id;
  final String transactionNumber;
  final String citizenName;
  final String documentType;
  final String status;
  final String? issuedAt;
  final Map<String, dynamic>? details;

  const VerifiedDocumentModel({
    this.id,
    required this.transactionNumber,
    required this.citizenName,
    required this.documentType,
    required this.status,
    this.issuedAt,
    this.details,
  });

  factory VerifiedDocumentModel.fromJson(Map<String, dynamic> json) {
    // API might wrap object inside 'data' or return top-level fields
    final Map<String, dynamic> data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final citizenData = data['citizen'] ?? data['user'] ?? data['owner'];
    String name = 'مواطن معتمد';
    if (citizenData is Map<String, dynamic>) {
      name = citizenData['name'] as String? ??
          citizenData['full_name'] as String? ??
          name;
    } else if (data['citizen_name'] is String) {
      name = data['citizen_name'] as String;
    } else if (data['citizenName'] is String) {
      name = data['citizenName'] as String;
    } else if (data['user_name'] is String) {
      name = data['user_name'] as String;
    } else if (data['name'] is String) {
      name = data['name'] as String;
    }

    final rawType = data['document_type'] as String? ??
        data['documentType'] as String? ??
        data['type'] as String? ??
        'وثيقة رقمية معتمدة';

    return VerifiedDocumentModel(
      id: data['id'] is int
          ? data['id'] as int
          : int.tryParse(data['id']?.toString() ?? ''),
      transactionNumber: data['transaction_number'] as String? ??
          data['transactionNumber'] as String? ??
          data['number'] as String? ??
          'غير معروف',
      citizenName: name,
      documentType: _translateType(rawType),
      status: data['status'] as String? ?? 'approved',
      issuedAt: data['issued_at'] as String? ??
          data['created_at'] as String? ??
          data['createdAt'] as String?,
      details: data['details'] is Map<String, dynamic>
          ? data['details'] as Map<String, dynamic>
          : null,
    );
  }

  static String _translateType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'commercial_license':
      case 'license':
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
        if (rawType.trim().isNotEmpty) {
          return rawType;
        }
        return 'وثيقة رسمية معتمدة';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'transaction_number': transactionNumber,
      'citizen_name': citizenName,
      'document_type': documentType,
      'status': status,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (details != null) 'details': details,
    };
  }
}
