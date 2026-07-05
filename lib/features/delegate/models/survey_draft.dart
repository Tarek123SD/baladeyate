import 'package:baladeyate/features/delegate/models/survey_resident.dart';

class SurveyDraft {
  const SurveyDraft({
    required this.pinId,
    required this.latitude,
    required this.longitude,
    this.buildingNumber = '',
    this.buildingName = '',
    this.buildingAddress = '',
    this.floorCount = '',
    this.buildingType,
    this.floorNumber = '',
    this.floorName = '',
    this.apartmentCount = '',
    this.floorPlanNumber = '',
    this.apartmentNumber = '',
    this.apartmentType = '',
    this.occupancyStatus = 'مسكون',
    this.roomCount = 3,
    this.residentCount = '',
    this.phone = '',
    this.residents = const [],
    this.isDataVerified = false,
  });

  final String pinId;
  final double latitude;
  final double longitude;

  final String buildingNumber;
  final String buildingName;
  final String buildingAddress;
  final String floorCount;
  final String? buildingType;

  final String floorNumber;
  final String floorName;
  final String apartmentCount;
  final String floorPlanNumber;

  final String apartmentNumber;
  final String apartmentType;
  final String occupancyStatus;
  final int roomCount;

  final String residentCount;
  final String phone;
  final List<SurveyResident> residents;
  final bool isDataVerified;

  SurveyDraft copyWith({
    String? pinId,
    double? latitude,
    double? longitude,
    String? buildingNumber,
    String? buildingName,
    String? buildingAddress,
    String? floorCount,
    String? buildingType,
    String? floorNumber,
    String? floorName,
    String? apartmentCount,
    String? floorPlanNumber,
    String? apartmentNumber,
    String? apartmentType,
    String? occupancyStatus,
    int? roomCount,
    String? residentCount,
    String? phone,
    List<SurveyResident>? residents,
    bool? isDataVerified,
  }) {
    return SurveyDraft(
      pinId: pinId ?? this.pinId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      buildingName: buildingName ?? this.buildingName,
      buildingAddress: buildingAddress ?? this.buildingAddress,
      floorCount: floorCount ?? this.floorCount,
      buildingType: buildingType ?? this.buildingType,
      floorNumber: floorNumber ?? this.floorNumber,
      floorName: floorName ?? this.floorName,
      apartmentCount: apartmentCount ?? this.apartmentCount,
      floorPlanNumber: floorPlanNumber ?? this.floorPlanNumber,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      apartmentType: apartmentType ?? this.apartmentType,
      occupancyStatus: occupancyStatus ?? this.occupancyStatus,
      roomCount: roomCount ?? this.roomCount,
      residentCount: residentCount ?? this.residentCount,
      phone: phone ?? this.phone,
      residents: residents ?? this.residents,
      isDataVerified: isDataVerified ?? this.isDataVerified,
    );
  }
}
