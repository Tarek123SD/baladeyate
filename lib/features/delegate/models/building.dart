class Building {
  const Building({
    required this.id,
    required this.name,
    this.realEstateNumber,
    this.licenseNumber,
    this.totalFloors,
    this.hasBasement,
    this.hasGarage,
    this.ownershipType,
    this.isIllegal,
    this.coordinates,
  });

  final int id;
  final String name;
  final String? realEstateNumber;
  final String? licenseNumber;
  final int? totalFloors;
  final bool? hasBasement;
  final bool? hasGarage;
  final String? ownershipType;
  final bool? isIllegal;
  final Map<String, dynamic>? coordinates;

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      realEstateNumber: json['real_estate_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      totalFloors: json['total_floors'] as int?,
      hasBasement: json['has_basement'] as bool?,
      hasGarage: json['has_garage'] as bool?,
      ownershipType: json['ownership_type'] as String?,
      isIllegal: json['is_illegal'] as bool?,
      coordinates: json['coordinates'] as Map<String, dynamic>?,
    );
  }
}
