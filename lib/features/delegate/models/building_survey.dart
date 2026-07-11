import 'package:baladeyate/features/delegate/models/survey_phase.dart';

/// Building fields mirror `POST /api/v1/buildings`.
class BuildingDraft {
  const BuildingDraft({
    this.name = '',
    this.realEstateNumber = '',
    this.licenseNumber = '',
    this.totalFloors = '',
    this.ownershipType,
    this.hasBasement = false,
    this.hasGarage = false,
    this.isIllegal = false,
    this.buildingImagePath,
  });

  final String name;
  final String realEstateNumber;
  final String licenseNumber;
  final String totalFloors;
  final String? ownershipType;
  final bool hasBasement;
  final bool hasGarage;
  final bool isIllegal;
  final String? buildingImagePath;

  BuildingDraft copyWith({
    String? name,
    String? realEstateNumber,
    String? licenseNumber,
    String? totalFloors,
    String? ownershipType,
    bool? hasBasement,
    bool? hasGarage,
    bool? isIllegal,
    String? buildingImagePath,
    bool clearBuildingImagePath = false,
  }) {
    return BuildingDraft(
      name: name ?? this.name,
      realEstateNumber: realEstateNumber ?? this.realEstateNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      totalFloors: totalFloors ?? this.totalFloors,
      ownershipType: ownershipType ?? this.ownershipType,
      hasBasement: hasBasement ?? this.hasBasement,
      hasGarage: hasGarage ?? this.hasGarage,
      isIllegal: isIllegal ?? this.isIllegal,
      buildingImagePath: clearBuildingImagePath
          ? null
          : (buildingImagePath ?? this.buildingImagePath),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'real_estate_number': realEstateNumber,
        'license_number': licenseNumber,
        'total_floors': totalFloors,
        if (ownershipType != null) 'ownership_type': ownershipType,
        'has_basement': hasBasement,
        'has_garage': hasGarage,
        'is_illegal': isIllegal,
        if (buildingImagePath != null) 'building_image_path': buildingImagePath,
      };

  factory BuildingDraft.fromJson(Map<String, dynamic> json) {
    return BuildingDraft(
      name: json['name'] as String? ?? '',
      realEstateNumber: json['real_estate_number'] as String? ?? '',
      licenseNumber: json['license_number'] as String? ?? '',
      totalFloors: json['total_floors'] as String? ?? '',
      ownershipType: json['ownership_type'] as String?,
      hasBasement: json['has_basement'] as bool? ?? false,
      hasGarage: json['has_garage'] as bool? ?? false,
      isIllegal: json['is_illegal'] as bool? ?? false,
      buildingImagePath: json['building_image_path'] as String?,
    );
  }
}

/// One survey unit = an apartment (`POST /api/v1/apartments`) plus its family
/// (`POST /api/v1/families`), saved together.
class ApartmentUnitDraft {
  const ApartmentUnitDraft({
    required this.localId,
    // Apartment fields
    this.floorType = 'residential',
    this.waterMeter = '',
    this.electricityMeter = '',
    this.landline = '',
    this.isSealed = false,
    // Family fields
    this.familyBook = '',
    this.healthStatus = 'good',
    this.livingStatus = 'medium',
    this.lastAidDate = '',
    this.unemployedCount = '',
    this.studentsCount = '',
    this.occupancyType = 'owner',
    // Local-only
    this.isDataVerified = false,
    this.apartmentId,
    this.familyId,
    this.isSaved = false,
  });

  final String localId;

  final String floorType;
  final String waterMeter;
  final String electricityMeter;
  final String landline;
  final bool isSealed;

  final String familyBook;
  final String healthStatus;
  final String livingStatus;
  final String lastAidDate;
  final String unemployedCount;
  final String studentsCount;
  final String occupancyType;

  final bool isDataVerified;
  final int? apartmentId;
  final int? familyId;
  final bool isSaved;

  ApartmentUnitDraft copyWith({
    String? localId,
    String? floorType,
    String? waterMeter,
    String? electricityMeter,
    String? landline,
    bool? isSealed,
    String? familyBook,
    String? healthStatus,
    String? livingStatus,
    String? lastAidDate,
    String? unemployedCount,
    String? studentsCount,
    String? occupancyType,
    bool? isDataVerified,
    int? apartmentId,
    int? familyId,
    bool? isSaved,
  }) {
    return ApartmentUnitDraft(
      localId: localId ?? this.localId,
      floorType: floorType ?? this.floorType,
      waterMeter: waterMeter ?? this.waterMeter,
      electricityMeter: electricityMeter ?? this.electricityMeter,
      landline: landline ?? this.landline,
      isSealed: isSealed ?? this.isSealed,
      familyBook: familyBook ?? this.familyBook,
      healthStatus: healthStatus ?? this.healthStatus,
      livingStatus: livingStatus ?? this.livingStatus,
      lastAidDate: lastAidDate ?? this.lastAidDate,
      unemployedCount: unemployedCount ?? this.unemployedCount,
      studentsCount: studentsCount ?? this.studentsCount,
      occupancyType: occupancyType ?? this.occupancyType,
      isDataVerified: isDataVerified ?? this.isDataVerified,
      apartmentId: apartmentId ?? this.apartmentId,
      familyId: familyId ?? this.familyId,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'floor_type': floorType,
        'water_meter': waterMeter,
        'electricity_meter': electricityMeter,
        'landline': landline,
        'is_sealed': isSealed,
        'family_book': familyBook,
        'health_status': healthStatus,
        'living_status': livingStatus,
        'last_aid_date': lastAidDate,
        'unemployed_count': unemployedCount,
        'students_count': studentsCount,
        'occupancy_type': occupancyType,
        'is_data_verified': isDataVerified,
        if (apartmentId != null) 'apartment_id': apartmentId,
        if (familyId != null) 'family_id': familyId,
        'is_saved': isSaved,
      };

  factory ApartmentUnitDraft.fromJson(Map<String, dynamic> json) {
    return ApartmentUnitDraft(
      localId: json['local_id'] as String? ?? '',
      floorType: json['floor_type'] as String? ?? 'residential',
      waterMeter: json['water_meter'] as String? ?? '',
      electricityMeter: json['electricity_meter'] as String? ?? '',
      landline: json['landline'] as String? ?? '',
      isSealed: json['is_sealed'] as bool? ?? false,
      familyBook: json['family_book'] as String? ?? '',
      healthStatus: json['health_status'] as String? ?? 'good',
      livingStatus: json['living_status'] as String? ?? 'medium',
      lastAidDate: json['last_aid_date'] as String? ?? '',
      unemployedCount: json['unemployed_count'] as String? ?? '',
      studentsCount: json['students_count'] as String? ?? '',
      occupancyType: json['occupancy_type'] as String? ?? 'owner',
      isDataVerified: json['is_data_verified'] as bool? ?? false,
      apartmentId: json['apartment_id'] as int?,
      familyId: json['family_id'] as int?,
      isSaved: json['is_saved'] as bool? ?? false,
    );
  }
}

class FloorDraft {
  const FloorDraft({
    required this.localId,
    this.floorNumber = '',
    this.floorName = '',
    this.expectedApartmentCount = '',
    this.floorPlanNumber = '',
    this.apartments = const [],
  });

  final String localId;
  final String floorNumber;
  final String floorName;
  final String expectedApartmentCount;
  final String floorPlanNumber;
  final List<ApartmentUnitDraft> apartments;

  int get savedApartmentCount =>
      apartments.where((apartment) => apartment.isSaved).length;

  FloorDraft copyWith({
    String? localId,
    String? floorNumber,
    String? floorName,
    String? expectedApartmentCount,
    String? floorPlanNumber,
    List<ApartmentUnitDraft>? apartments,
  }) {
    return FloorDraft(
      localId: localId ?? this.localId,
      floorNumber: floorNumber ?? this.floorNumber,
      floorName: floorName ?? this.floorName,
      expectedApartmentCount:
          expectedApartmentCount ?? this.expectedApartmentCount,
      floorPlanNumber: floorPlanNumber ?? this.floorPlanNumber,
      apartments: apartments ?? this.apartments,
    );
  }

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'floor_number': floorNumber,
        'floor_name': floorName,
        'expected_apartment_count': expectedApartmentCount,
        'floor_plan_number': floorPlanNumber,
        'apartments': apartments.map((a) => a.toJson()).toList(),
      };

  factory FloorDraft.fromJson(Map<String, dynamic> json) {
    final apartmentsRaw = json['apartments'];
    return FloorDraft(
      localId: json['local_id'] as String? ?? '',
      floorNumber: json['floor_number'] as String? ?? '',
      floorName: json['floor_name'] as String? ?? '',
      expectedApartmentCount:
          json['expected_apartment_count'] as String? ?? '',
      floorPlanNumber: json['floor_plan_number'] as String? ?? '',
      apartments: apartmentsRaw is List
          ? apartmentsRaw
              .whereType<Map<String, dynamic>>()
              .map(ApartmentUnitDraft.fromJson)
              .toList()
          : const [],
    );
  }
}

class BuildingSurvey {
  const BuildingSurvey({
    required this.pinId,
    required this.latitude,
    required this.longitude,
    this.buildingId,
    this.phase = SurveyPhase.buildingPending,
    this.building = const BuildingDraft(),
    this.floors = const [],
    this.currentApartment,
    this.currentFloorLocalId,
  });

  final String pinId;
  final double latitude;
  final double longitude;
  final int? buildingId;
  final SurveyPhase phase;
  final BuildingDraft building;
  final List<FloorDraft> floors;
  final ApartmentUnitDraft? currentApartment;
  final String? currentFloorLocalId;

  int get totalSavedApartments => floors.fold(
        0,
        (sum, floor) => sum + floor.savedApartmentCount,
      );

  FloorDraft? floorByLocalId(String localId) {
    for (final floor in floors) {
      if (floor.localId == localId) return floor;
    }
    return null;
  }

  BuildingSurvey copyWith({
    String? pinId,
    double? latitude,
    double? longitude,
    int? buildingId,
    SurveyPhase? phase,
    BuildingDraft? building,
    List<FloorDraft>? floors,
    ApartmentUnitDraft? currentApartment,
    String? currentFloorLocalId,
    bool clearCurrentApartment = false,
    bool clearCurrentFloorLocalId = false,
  }) {
    return BuildingSurvey(
      pinId: pinId ?? this.pinId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      buildingId: buildingId ?? this.buildingId,
      phase: phase ?? this.phase,
      building: building ?? this.building,
      floors: floors ?? this.floors,
      currentApartment: clearCurrentApartment
          ? null
          : (currentApartment ?? this.currentApartment),
      currentFloorLocalId: clearCurrentFloorLocalId
          ? null
          : (currentFloorLocalId ?? this.currentFloorLocalId),
    );
  }

  Map<String, dynamic> toJson() => {
        'pin_id': pinId,
        'latitude': latitude,
        'longitude': longitude,
        if (buildingId != null) 'building_id': buildingId,
        'phase': phase.storageValue,
        'building': building.toJson(),
        'floors': floors.map((f) => f.toJson()).toList(),
        if (currentApartment != null)
          'current_apartment': currentApartment!.toJson(),
        if (currentFloorLocalId != null)
          'current_floor_local_id': currentFloorLocalId,
      };

  factory BuildingSurvey.fromJson(Map<String, dynamic> json) {
    final floorsRaw = json['floors'];
    final currentApartmentRaw = json['current_apartment'];
    return BuildingSurvey(
      pinId: json['pin_id'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      buildingId: json['building_id'] as int?,
      phase: SurveyPhase.fromString(json['phase'] as String?),
      building: json['building'] is Map<String, dynamic>
          ? BuildingDraft.fromJson(json['building'] as Map<String, dynamic>)
          : const BuildingDraft(),
      floors: floorsRaw is List
          ? floorsRaw
              .whereType<Map<String, dynamic>>()
              .map(FloorDraft.fromJson)
              .toList()
          : const [],
      currentApartment: currentApartmentRaw is Map<String, dynamic>
          ? ApartmentUnitDraft.fromJson(currentApartmentRaw)
          : null,
      currentFloorLocalId: json['current_floor_local_id'] as String?,
    );
  }
}
