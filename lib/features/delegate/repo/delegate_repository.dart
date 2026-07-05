import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/delegate/data/local_survey_pin_store.dart';
import 'package:baladeyate/features/delegate/models/survey_draft.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_submission_result.dart';

class DelegateRepository {
  DelegateRepository({
    required ApiService apiService,
    required LocalSurveyPinStore localSurveyPinStore,
  })  : _apiService = apiService,
        _localSurveyPinStore = localSurveyPinStore;

  final ApiService _apiService;
  final LocalSurveyPinStore _localSurveyPinStore;

  Future<List<SurveyPin>> getMapPins() async {
    final remotePins = await _fetchCompletedPins();
    final draftPins = await _localSurveyPinStore.loadDraftPins();
    return _mergePins(remotePins, draftPins);
  }

  Future<SurveySubmissionResult> submitSurvey(SurveyDraft draft) async {
    try {
      final buildingId = await _createBuilding(draft);
      final apartmentId = await _createApartment(draft, buildingId);
      final familyId = await _createFamily(draft, apartmentId);
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

  Future<int> _createBuilding(SurveyDraft draft) async {
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

  Future<int> _createApartment(SurveyDraft draft, int buildingId) async {
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

  Future<int> _createFamily(SurveyDraft draft, int apartmentId) async {
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

    for (final pin in remotePins) {
      merged[pin.id] = pin;
    }

    for (final pin in draftPins) {
      merged[pin.id] = pin;
    }

    return merged.values.toList();
  }
}
