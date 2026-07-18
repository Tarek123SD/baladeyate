import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/delegate/models/apartment.dart';
import 'package:baladeyate/features/delegate/models/building.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/models/family.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';
import 'package:baladeyate/features/delegate/data/local_survey_pin_store.dart';
import 'package:baladeyate/features/delegate/models/survey_draft.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/features/delegate/models/survey_submission_result.dart';

class DelegateRepository {
  DelegateRepository({
    required ApiService apiService,
    required LocalSurveyPinStore localSurveyPinStore,
  })  : _apiService = apiService,
        _localSurveyPinStore = localSurveyPinStore;

  final ApiService _apiService;
  final LocalSurveyPinStore _localSurveyPinStore;

  // --- Buildings ---

  Future<List<Building>> getBuildings() async {
    try {
      final response = await _apiService.get(EndPoints.buildings);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: Building.fromJson,
        fallback: 'فشل تحميل المباني',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل المباني');
    }
  }

  Future<Building> getBuildingById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.buildingById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Building.fromJson,
        fallback: 'فشل تحميل المبنى',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل المبنى');
    }
  }

  Future<Building> createBuilding({
    required String name,
    required String realEstateNumber,
    required String licenseNumber,
    required int totalFloors,
    required bool hasBasement,
    required bool hasGarage,
    required String ownershipType,
    required bool isIllegal,
    Map<String, dynamic>? coordinates,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.buildings,
        data: {
          'name': name,
          'real_estate_number': realEstateNumber,
          'license_number': licenseNumber,
          'total_floors': totalFloors,
          'has_basement': hasBasement,
          'has_garage': hasGarage,
          'ownership_type': ownershipType,
          'is_illegal': isIllegal,
          if (coordinates != null) 'coordinates': coordinates,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Building.fromJson,
        fallback: 'فشل إنشاء المبنى',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إنشاء المبنى');
    }
  }

  Future<Building> updateBuilding({
    required int id,
    String? name,
    int? totalFloors,
    bool? hasBasement,
    bool? hasGarage,
    String? ownershipType,
    bool? isIllegal,
    Map<String, dynamic>? coordinates,
  }) async {
    try {
      final response = await _apiService.put(
        EndPoints.buildingById(id),
        data: {
          if (name != null) 'name': name,
          if (totalFloors != null) 'total_floors': totalFloors,
          if (hasBasement != null) 'has_basement': hasBasement,
          if (hasGarage != null) 'has_garage': hasGarage,
          if (ownershipType != null) 'ownership_type': ownershipType,
          if (isIllegal != null) 'is_illegal': isIllegal,
          if (coordinates != null) 'coordinates': coordinates,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Building.fromJson,
        fallback: 'فشل تحديث المبنى',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحديث المبنى');
    }
  }

  Future<void> deleteBuilding(int id) async {
    try {
      final response = await _apiService.delete(
        EndPoints.buildingById(id),
        data: const {},
      );
      ApiResponseParser.expectMap(response.data, fallback: 'فشل حذف المبنى');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل حذف المبنى');
    }
  }

  // --- Apartments ---

  Future<List<Apartment>> getApartments() async {
    try {
      final response = await _apiService.get(EndPoints.apartments);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: Apartment.fromJson,
        fallback: 'فشل تحميل الشقق',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الشقق');
    }
  }

  Future<Apartment> getApartmentById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.apartmentById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Apartment.fromJson,
        fallback: 'فشل تحميل الشقة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الشقة');
    }
  }

  Future<Apartment> createApartment({
    required int buildingId,
    required String floorType,
    String? waterMeter,
    String? electricityMeter,
    String? landline,
    bool isSealed = false,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.apartments,
        data: {
          'building_id': buildingId,
          'floor_type': floorType,
          if (waterMeter != null) 'water_meter': waterMeter,
          if (electricityMeter != null) 'electricity_meter': electricityMeter,
          if (landline != null) 'landline': landline,
          'is_sealed': isSealed,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Apartment.fromJson,
        fallback: 'فشل إنشاء الشقة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إنشاء الشقة');
    }
  }

  Future<Apartment> updateApartment({
    required int id,
    String? floorType,
    String? waterMeter,
    String? electricityMeter,
    String? landline,
    bool? isSealed,
  }) async {
    try {
      final response = await _apiService.put(
        EndPoints.apartmentById(id),
        data: {
          if (floorType != null) 'floor_type': floorType,
          if (waterMeter != null) 'water_meter': waterMeter,
          if (electricityMeter != null) 'electricity_meter': electricityMeter,
          if (landline != null) 'landline': landline,
          if (isSealed != null) 'is_sealed': isSealed,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Apartment.fromJson,
        fallback: 'فشل تحديث الشقة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحديث الشقة');
    }
  }

  Future<void> deleteApartment(int id) async {
    try {
      final response = await _apiService.delete(
        EndPoints.apartmentById(id),
        data: const {},
      );
      ApiResponseParser.expectMap(response.data, fallback: 'فشل حذف الشقة');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل حذف الشقة');
    }
  }

  // --- Families ---

  Future<List<Family>> getFamilies() async {
    try {
      final response = await _apiService.get(EndPoints.families);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: Family.fromJson,
        fallback: 'فشل تحميل العائلات',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل العائلات');
    }
  }

  Future<Family> getFamilyById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.familyById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Family.fromJson,
        fallback: 'فشل تحميل العائلة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل العائلة');
    }
  }

  Future<Family> createFamily({
    required int apartmentId,
    required String familyBook,
    required String healthStatus,
    required String livingStatus,
    String? lastAidDate,
    int unemployedCount = 0,
    int studentsCount = 0,
    required String occupancyType,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.families,
        data: {
          'apartment_id': apartmentId,
          'family_book': familyBook,
          'health_status': healthStatus,
          'living_status': livingStatus,
          if (lastAidDate != null) 'last_aid_date': lastAidDate,
          'unemployed_count': unemployedCount,
          'students_count': studentsCount,
          'occupancy_type': occupancyType,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Family.fromJson,
        fallback: 'فشل إنشاء العائلة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إنشاء العائلة');
    }
  }

  Future<Family> updateFamily({
    required int id,
    String? familyBook,
    String? healthStatus,
    String? livingStatus,
    String? lastAidDate,
    int? unemployedCount,
    int? studentsCount,
    String? occupancyType,
  }) async {
    try {
      final response = await _apiService.put(
        EndPoints.familyById(id),
        data: {
          if (familyBook != null) 'family_book': familyBook,
          if (healthStatus != null) 'health_status': healthStatus,
          if (livingStatus != null) 'living_status': livingStatus,
          if (lastAidDate != null) 'last_aid_date': lastAidDate,
          if (unemployedCount != null) 'unemployed_count': unemployedCount,
          if (studentsCount != null) 'students_count': studentsCount,
          if (occupancyType != null) 'occupancy_type': occupancyType,
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: Family.fromJson,
        fallback: 'فشل تحديث العائلة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحديث العائلة');
    }
  }

  Future<void> deleteFamily(int id) async {
    try {
      final response = await _apiService.delete(
        EndPoints.familyById(id),
        data: const {},
      );
      ApiResponseParser.expectMap(response.data, fallback: 'فشل حذف العائلة');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل حذف العائلة');
    }
  }

  // --- Households ---

  Future<RegisteredHousehold> registerHousehold({
    required String address,
    required List<HouseholdMemberInput> members,
    String? electricityMeterNumber,
    String? waterMeterNumber,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.households,
        data: {
          'address': address,
          if (electricityMeterNumber != null)
            'electricity_meter_number': electricityMeterNumber,
          if (waterMeterNumber != null)
            'water_meter_number': waterMeterNumber,
          'members': members.map((member) => member.toJson()).toList(),
        },
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: RegisteredHousehold.fromJson,
        fallback: 'فشل تسجيل الأسرة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تسجيل الأسرة');
    }
  }

  // --- My Field Tasks ---

  Future<List<DelegateTask>> getMyTasks() async {
    try {
      final response = await _apiService.get(EndPoints.delegateMyTasks);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: DelegateTask.fromJson,
        fallback: 'فشل تحميل المهام الميدانية',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل المهام الميدانية',
      );
    }
  }

  Future<DelegateTask> getMyTaskById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.delegateMyTaskById(id));
      return ApiResponseParser.parseItem(
        response.data,
        fromJson: DelegateTask.fromJson,
        fallback: 'فشل تحميل المهمة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل المهمة');
    }
  }

  Future<DelegateTask> updateMyTaskStatus({
    required int id,
    required String status,
  }) async {
    try {
      final response = await _apiService.patch(
        EndPoints.delegateMyTaskStatus(id),
        data: {'status': status},
      );

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: DelegateTask.fromJson,
        fallback: 'فشل تحديث حالة المهمة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحديث حالة المهمة',
      );
    }
  }

  // --- Map survey pins ---

  Future<List<SurveyPin>> getMapPins() async {
    final remotePins = await _fetchCompletedPins();
    final draftPins = await _localSurveyPinStore.loadDraftPins();
    return _mergePins(remotePins, draftPins);
  }

  Future<SurveySubmissionResult> submitSurvey(SurveyDraft draft) async {
    try {
      final buildingId = await _createSurveyBuilding(draft);
      final apartmentId = await _createSurveyApartment(draft, buildingId);
      final familyId = await _createSurveyFamily(draft, apartmentId);
      await _localSurveyPinStore.removeDraftPin(draft.pinId);

      return SurveySubmissionResult(
        buildingId: buildingId,
        apartmentId: apartmentId,
        familyId: familyId,
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل حفظ بيانات المسح');
    }
  }

  Future<void> saveDraftPin(SurveyPin pin) {
    return _localSurveyPinStore.saveDraftPin(pin);
  }

  Future<void> updateDraftPin(SurveyPin pin) => saveDraftPin(pin);

  Future<int> createSurveyBuildingOnly({
    required BuildingDraft building,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.buildings,
        data: {
          'name': building.name,
          'real_estate_number': building.realEstateNumber,
          'license_number': building.licenseNumber,
          'total_floors':
              int.tryParse(building.totalFloors) ?? building.totalFloors,
          'has_basement': building.hasBasement,
          'has_garage': building.hasGarage,
          'is_illegal': building.isIllegal,
          if (building.ownershipType != null)
            'ownership_type': building.ownershipType,
          'coordinates': {'lat': latitude, 'lng': longitude},
        },
      );
      return _readEntityId(response.data, 'building');
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل حفظ بيانات المبنى',
      );
    }
  }

  Future<({int apartmentId, int familyId})> createSurveyApartmentAndFamily({
    required int buildingId,
    required ApartmentUnitDraft unit,
  }) async {
    try {
      final apartmentResponse = await _apiService.post(
        EndPoints.apartments,
        data: {
          'building_id': buildingId,
          'floor_type': unit.floorType,
          'water_meter': unit.waterMeter,
          'electricity_meter': unit.electricityMeter,
          'landline': unit.landline,
          'is_sealed': unit.isSealed,
        },
      );
      final apartmentId = _readEntityId(apartmentResponse.data, 'apartment');

      final familyResponse = await _apiService.post(
        EndPoints.families,
        data: {
          'apartment_id': apartmentId,
          'family_book': unit.familyBook,
          'health_status': unit.healthStatus,
          'living_status': unit.livingStatus,
          if (unit.lastAidDate.isNotEmpty) 'last_aid_date': unit.lastAidDate,
          'unemployed_count':
              int.tryParse(unit.unemployedCount) ?? unit.unemployedCount,
          'students_count':
              int.tryParse(unit.studentsCount) ?? unit.studentsCount,
          'occupancy_type': unit.occupancyType,
        },
      );
      final familyId = _readEntityId(familyResponse.data, 'family');

      return (apartmentId: apartmentId, familyId: familyId);
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل حفظ بيانات الشقة',
      );
    }
  }

  /// Updates an already-saved apartment + family during survey review/edit.
  Future<({int apartmentId, int familyId})> updateSurveyApartmentAndFamily({
    required ApartmentUnitDraft unit,
  }) async {
    final apartmentId = unit.apartmentId;
    final familyId = unit.familyId;
    if (apartmentId == null || familyId == null) {
      throw Exception('لا يمكن تحديث شقة غير محفوظة على الخادم');
    }

    try {
      await updateApartment(
        id: apartmentId,
        floorType: unit.floorType,
        waterMeter: unit.waterMeter,
        electricityMeter: unit.electricityMeter,
        landline: unit.landline,
        isSealed: unit.isSealed,
      );
      await updateFamily(
        id: familyId,
        familyBook: unit.familyBook,
        healthStatus: unit.healthStatus,
        livingStatus: unit.livingStatus,
        lastAidDate: unit.lastAidDate.isNotEmpty ? unit.lastAidDate : null,
        unemployedCount: int.tryParse(unit.unemployedCount),
        studentsCount: int.tryParse(unit.studentsCount),
        occupancyType: unit.occupancyType,
      );
      return (apartmentId: apartmentId, familyId: familyId);
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحديث بيانات الشقة',
      );
    }
  }

  Future<List<SurveyPin>> _fetchCompletedPins() async {
    try {
      final response = await _apiService.get(EndPoints.buildings);
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(SurveyPin.fromBuildingJson)
            .where((pin) => pin.latitude != 0 && pin.longitude != 0)
            .toList();
      }
      return _parseBuildingPins(data);
    } catch (_) {
      return [];
    }
  }

  List<SurveyPin> _parseBuildingPins(dynamic data) {
    final payload = data is Map<String, dynamic>
        ? ApiResponseParser.expectData(data)
        : data;

    final items = payload is List
        ? payload
        : payload is Map<String, dynamic> && payload['data'] is List
            ? payload['data'] as List
            : <dynamic>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(SurveyPin.fromBuildingJson)
        .where((pin) => pin.latitude != 0 && pin.longitude != 0)
        .toList();
  }

  Future<int> _createSurveyBuilding(SurveyDraft draft) async {
    final response = await _apiService.post(
      EndPoints.buildings,
      data: {
        'building_number': draft.buildingNumber,
        'name': draft.buildingName,
        'address': draft.buildingAddress,
        'latitude': draft.latitude,
        'longitude': draft.longitude,
        'floors_count': int.tryParse(draft.floorCount) ?? draft.floorCount,
        if (draft.buildingType != null) 'building_type': draft.buildingType,
        'floor_number': draft.floorNumber,
        'floor_name': draft.floorName,
        'apartments_count': int.tryParse(draft.apartmentCount) ??
            draft.apartmentCount,
        'floor_plan_number': draft.floorPlanNumber,
      },
    );

    return _readEntityId(response.data, 'building');
  }

  Future<int> _createSurveyApartment(SurveyDraft draft, int buildingId) async {
    final response = await _apiService.post(
      EndPoints.apartments,
      data: {
        'building_id': buildingId,
        'apartment_number': draft.apartmentNumber,
        'apartment_type': draft.apartmentType,
        'occupancy_status': draft.occupancyStatus,
        'room_count': draft.roomCount,
        'floor_number': draft.floorNumber,
      },
    );

    return _readEntityId(response.data, 'apartment');
  }

  Future<int> _createSurveyFamily(SurveyDraft draft, int apartmentId) async {
    final response = await _apiService.post(
      EndPoints.families,
      data: {
        'apartment_id': apartmentId,
        'phone_number': draft.phone,
        'resident_count': int.tryParse(draft.residentCount) ??
            draft.residentCount,
        'members': draft.residents.map((resident) => resident.toJson()).toList(),
        'is_verified': draft.isDataVerified,
      },
    );

    return _readEntityId(response.data, 'family');
  }

  int _readEntityId(dynamic data, String fallbackKey) {
    if (data is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      final id = payload['id'];
      if (id is int) return id;
      final parsed = int.tryParse(id?.toString() ?? '');
      if (parsed != null) return parsed;
    }

    final rootId = data['id'];
    if (rootId is int) return rootId;

    final parsedRoot = int.tryParse(rootId?.toString() ?? '');
    if (parsedRoot != null) return parsedRoot;

    throw Exception('تعذر قراءة معرف $fallbackKey من الخادم');
  }

  List<SurveyPin> _mergePins(
    List<SurveyPin> remotePins,
    List<SurveyPin> draftPins,
  ) {
    final merged = <String, SurveyPin>{};
    final remoteByBuildingId = <int, String>{};

    for (final pin in remotePins) {
      merged[pin.id] = pin;
      final buildingId = pin.buildingId;
      if (buildingId != null) {
        remoteByBuildingId[buildingId] = pin.id;
      }
    }

    for (final pin in draftPins) {
      final buildingId = pin.buildingId;
      final remoteId =
          buildingId != null ? remoteByBuildingId[buildingId] : null;

      // Same building already came from GET /buildings.
      if (remoteId != null) {
        if (pin.status == SurveyPinStatus.inProgress) {
          // Keep the local draft so the delegate can resume editing,
          // keyed by the local pin id; drop the remote duplicate.
          merged.remove(remoteId);
          merged[pin.id] = pin;
        }
        // Completed local drafts are superseded by the remote pin.
        continue;
      }

      merged[pin.id] = pin;
    }

    return merged.values.toList();
  }
}
