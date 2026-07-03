class Family {
  const Family({
    required this.id,
    required this.apartmentId,
    this.familyBook,
    this.healthStatus,
    this.livingStatus,
    this.lastAidDate,
    this.unemployedCount,
    this.studentsCount,
    this.occupancyType,
  });

  final int id;
  final int apartmentId;
  final String? familyBook;
  final String? healthStatus;
  final String? livingStatus;
  final String? lastAidDate;
  final int? unemployedCount;
  final int? studentsCount;
  final String? occupancyType;

  factory Family.fromJson(Map<String, dynamic> json) {
    return Family(
      id: json['id'] as int? ?? 0,
      apartmentId: json['apartment_id'] as int? ?? 0,
      familyBook: json['family_book'] as String?,
      healthStatus: json['health_status'] as String?,
      livingStatus: json['living_status'] as String?,
      lastAidDate: json['last_aid_date'] as String?,
      unemployedCount: json['unemployed_count'] as int?,
      studentsCount: json['students_count'] as int?,
      occupancyType: json['occupancy_type'] as String?,
    );
  }
}
