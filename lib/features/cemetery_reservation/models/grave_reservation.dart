class GraveReservation {
  const GraveReservation({
    required this.id,
    required this.reservationNumber,
    required this.deceasedName,
    required this.status,
    required this.statusLabel,
    this.notes,
    this.adminNotes,
    this.graveId,
    this.createdAt,
  });

  final int id;
  final String reservationNumber;
  final String deceasedName;
  final String status;
  final String statusLabel;
  final String? notes;
  final String? adminNotes;
  final int? graveId;
  final String? createdAt;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => isPending;

  factory GraveReservation.fromJson(Map<String, dynamic> json) {
    final grave = json['grave'];
    int? graveId;
    if (grave is Map<String, dynamic>) {
      final raw = grave['id'];
      if (raw is int) {
        graveId = raw;
      } else if (raw is String) {
        graveId = int.tryParse(raw);
      }
    }

    return GraveReservation(
      id: _readInt(json['id']) ?? 0,
      reservationNumber: json['reservation_number']?.toString() ?? '',
      deceasedName: json['deceased_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      statusLabel: json['status_label']?.toString() ?? '',
      notes: json['notes']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      graveId: graveId ?? _readInt(json['grave_id']),
      createdAt: json['created_at']?.toString(),
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
