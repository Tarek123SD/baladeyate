class Grave {
  const Grave({
    required this.id,
    this.familyId,
    this.blockName,
    this.rowNumber,
    this.status,
    this.statusLabel,
  });

  final int id;
  final int? familyId;
  final String? blockName;
  final int? rowNumber;
  final String? status;
  final String? statusLabel;

  String get displayTitle {
    if (blockName != null && rowNumber != null) {
      return 'قطعة $blockName - صف $rowNumber';
    }
    if (blockName != null) {
      return 'قطعة $blockName';
    }
    return 'قبر #$id';
  }

  String get displayStatus {
    if (statusLabel?.isNotEmpty == true) {
      return statusLabel!;
    }

    return switch (status) {
      'available' => 'متاح',
      'occupied' => 'مشغول',
      'reserved' => 'محجوز',
      _ => status ?? 'غير معروف',
    };
  }

  bool matchesQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    return displayTitle.toLowerCase().contains(normalized) ||
        displayStatus.toLowerCase().contains(normalized) ||
        id.toString().contains(normalized) ||
        (familyId?.toString().contains(normalized) ?? false);
  }

  factory Grave.fromJson(Map<String, dynamic> json) {
    return Grave(
      id: json['id'] as int? ?? 0,
      familyId: json['family_id'] as int?,
      blockName: json['block_name'] as String?,
      rowNumber: json['row_number'] as int?,
      status: json['status'] as String?,
      statusLabel: json['status_label'] as String?,
    );
  }
}
