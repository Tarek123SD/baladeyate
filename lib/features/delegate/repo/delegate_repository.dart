import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/delegate/models/apartment.dart';
import 'package:baladeyate/features/delegate/models/building.dart';
import 'package:baladeyate/features/delegate/models/delegate_task.dart';
import 'package:baladeyate/features/delegate/models/family.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';

class DelegateRepository {
  DelegateRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

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
}
