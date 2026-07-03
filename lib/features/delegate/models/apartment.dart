class Apartment {
  const Apartment({
    required this.id,
    required this.buildingId,
    this.floorType,
    this.waterMeter,
    this.electricityMeter,
    this.landline,
    this.isSealed,
  });

  final int id;
  final int buildingId;
  final String? floorType;
  final String? waterMeter;
  final String? electricityMeter;
  final String? landline;
  final bool? isSealed;

  factory Apartment.fromJson(Map<String, dynamic> json) {
    return Apartment(
      id: json['id'] as int? ?? 0,
      buildingId: json['building_id'] as int? ?? 0,
      floorType: json['floor_type'] as String?,
      waterMeter: json['water_meter'] as String?,
      electricityMeter: json['electricity_meter'] as String?,
      landline: json['landline'] as String?,
      isSealed: json['is_sealed'] as bool?,
    );
  }
}
