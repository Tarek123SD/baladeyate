import 'dart:async';

import 'package:baladeyate/features/delegate/data/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'building_survey_state.dart';

class BuildingSurveyCubit extends Cubit<BuildingSurveyState> {
  BuildingSurveyCubit({
    required DelegateRepository delegateRepository,
    required LocalBuildingSurveyStore localSurveyStore,
  })  : _delegateRepository = delegateRepository,
        _localSurveyStore = localSurveyStore,
        super(const BuildingSurveyInitial());

  final DelegateRepository _delegateRepository;
  final LocalBuildingSurveyStore _localSurveyStore;

  Timer? _persistDebounce;
  BuildingSurvey? _pendingSurvey;

  @override
  Future<void> close() {
    _persistDebounce?.cancel();
    final pending = _pendingSurvey;
    if (pending != null) {
      _localSurveyStore.saveSurvey(pending);
    }
    return super.close();
  }

  BuildingSurvey? get _survey => switch (state) {
        BuildingSurveyLoaded(:final survey) => survey,
        BuildingSurveySaving(:final survey) => survey,
        BuildingSurveyFailure(:final survey) => survey,
        _ => null,
      };

  Future<void> initFromPin(SurveyLocation location) async {
    final existing = await _localSurveyStore.loadSurvey(location.pinId);
    if (existing != null) {
      emit(BuildingSurveyLoaded(survey: existing));
      return;
    }

    final survey = BuildingSurvey(
      pinId: location.pinId,
      latitude: location.latitude,
      longitude: location.longitude,
    );
    await _persist(survey);
    emit(BuildingSurveyLoaded(survey: survey));
  }

  Future<void> loadSurvey(String pinId) async {
    final survey = await _localSurveyStore.loadSurvey(pinId);
    if (survey == null) {
      emit(const BuildingSurveyInitial());
      return;
    }
    emit(BuildingSurveyLoaded(survey: survey));
  }

  Future<void> updateBuilding({
    String? name,
    String? realEstateNumber,
    String? licenseNumber,
    String? totalFloors,
    String? ownershipType,
    bool? hasBasement,
    bool? hasGarage,
    bool? isIllegal,
    String? buildingImagePath,
  }) async {
    final current = _survey;
    if (current == null) return;

    final updated = current.copyWith(
      building: current.building.copyWith(
        name: name,
        realEstateNumber: realEstateNumber,
        licenseNumber: licenseNumber,
        totalFloors: totalFloors,
        ownershipType: ownershipType,
        hasBasement: hasBasement,
        hasGarage: hasGarage,
        isIllegal: isIllegal,
        buildingImagePath: buildingImagePath,
      ),
    );
    await _emitAndPersist(updated);
  }

  Future<bool> saveBuilding() async {
    final current = _survey;
    if (current == null) return false;

    await flush();
    emit(BuildingSurveySaving(survey: current));
    try {
      final buildingId = await _delegateRepository.createSurveyBuildingOnly(
        building: current.building,
        latitude: current.latitude,
        longitude: current.longitude,
      );

      await _delegateRepository.updateDraftPin(
        SurveyPin(
          id: current.pinId,
          latitude: current.latitude,
          longitude: current.longitude,
          status: SurveyPinStatus.inProgress,
          buildingId: buildingId,
          title: current.building.name.isNotEmpty
              ? current.building.name
              : 'مسح جديد',
          address: current.building.realEstateNumber,
        ),
      );

      final updated = current.copyWith(
        buildingId: buildingId,
        phase: SurveyPhase.floorsInProgress,
      );
      await _emitAndPersist(updated);
      return true;
    } catch (error) {
      emit(
        BuildingSurveyFailure(
          survey: current,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<void> saveFloor({
    required String? floorLocalId,
    required String floorNumber,
    required String floorName,
    required String expectedApartmentCount,
    required String floorPlanNumber,
  }) async {
    final current = _survey;
    if (current == null) return;

    final floors = List<FloorDraft>.from(current.floors);
    if (floorLocalId != null) {
      final index = floors.indexWhere((f) => f.localId == floorLocalId);
      if (index >= 0) {
        floors[index] = floors[index].copyWith(
          floorNumber: floorNumber,
          floorName: floorName,
          expectedApartmentCount: expectedApartmentCount,
          floorPlanNumber: floorPlanNumber,
        );
      }
    } else {
      floors.add(
        FloorDraft(
          localId: newLocalId('floor'),
          floorNumber: floorNumber,
          floorName: floorName,
          expectedApartmentCount: expectedApartmentCount,
          floorPlanNumber: floorPlanNumber,
        ),
      );
    }

    await _emitAndPersist(current.copyWith(floors: floors));
  }

  Future<void> startNewApartment(String floorLocalId) async {
    final current = _survey;
    if (current == null) return;

    await _emitAndPersist(
      current.copyWith(
        currentFloorLocalId: floorLocalId,
        currentApartment: ApartmentUnitDraft(localId: newLocalId('apt')),
        clearCurrentApartment: false,
      ),
    );
  }

  /// Loads an existing apartment unit for review / edit.
  Future<void> editApartmentUnit({
    required String floorLocalId,
    required String apartmentLocalId,
  }) async {
    final current = _survey;
    if (current == null) return;

    final floor = current.floorByLocalId(floorLocalId);
    if (floor == null) return;

    final matches =
        floor.apartments.where((a) => a.localId == apartmentLocalId);
    if (matches.isEmpty) return;
    final unit = matches.first;

    await _emitAndPersist(
      current.copyWith(
        currentFloorLocalId: floorLocalId,
        currentApartment: unit,
        clearCurrentApartment: false,
      ),
    );
  }

  Future<void> updateCurrentApartment({
    String? floorType,
    String? waterMeter,
    String? electricityMeter,
    String? landline,
    bool? isSealed,
  }) async {
    final current = _survey;
    if (current == null || current.currentApartment == null) return;

    await _emitAndPersist(
      current.copyWith(
        currentApartment: current.currentApartment!.copyWith(
          floorType: floorType,
          waterMeter: waterMeter,
          electricityMeter: electricityMeter,
          landline: landline,
          isSealed: isSealed,
        ),
      ),
    );
  }

  Future<void> updateCurrentFamily({
    String? familyBook,
    String? healthStatus,
    String? livingStatus,
    String? lastAidDate,
    String? unemployedCount,
    String? studentsCount,
    String? occupancyType,
    bool? isDataVerified,
  }) async {
    final current = _survey;
    if (current == null || current.currentApartment == null) return;

    await _emitAndPersist(
      current.copyWith(
        currentApartment: current.currentApartment!.copyWith(
          familyBook: familyBook,
          healthStatus: healthStatus,
          livingStatus: livingStatus,
          lastAidDate: lastAidDate,
          unemployedCount: unemployedCount,
          studentsCount: studentsCount,
          occupancyType: occupancyType,
          isDataVerified: isDataVerified,
        ),
      ),
    );
  }

  Future<bool> saveApartmentUnit() async {
    final current = _survey;
    if (current == null ||
        current.buildingId == null ||
        current.currentFloorLocalId == null ||
        current.currentApartment == null) {
      return false;
    }

    final floorLocalId = current.currentFloorLocalId!;
    final floor = current.floorByLocalId(floorLocalId);
    if (floor == null) return false;

    final unit = current.currentApartment!;
    await flush();
    emit(BuildingSurveySaving(survey: current));

    try {
      final isUpdate = unit.isSaved &&
          unit.apartmentId != null &&
          unit.familyId != null;

      final result = isUpdate
          ? await _delegateRepository.updateSurveyApartmentAndFamily(unit: unit)
          : await _delegateRepository.createSurveyApartmentAndFamily(
              buildingId: current.buildingId!,
              unit: unit,
            );

      final savedUnit = unit.copyWith(
        apartmentId: result.apartmentId,
        familyId: result.familyId,
        isSaved: true,
      );

      final floors = current.floors.map((f) {
        if (f.localId != floorLocalId) return f;
        final apartments = List<ApartmentUnitDraft>.from(f.apartments);
        final existingIndex =
            apartments.indexWhere((a) => a.localId == savedUnit.localId);
        if (existingIndex >= 0) {
          apartments[existingIndex] = savedUnit;
        } else {
          apartments.add(savedUnit);
        }
        return f.copyWith(apartments: apartments);
      }).toList();

      final updated = current.copyWith(
        floors: floors,
        clearCurrentApartment: true,
        clearCurrentFloorLocalId: true,
      );
      await _emitAndPersist(updated);
      return true;
    } catch (error) {
      emit(
        BuildingSurveyFailure(
          survey: current,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return false;
    }
  }

  Future<void> markBuildingComplete() async {
    final current = _survey;
    if (current == null) return;

    await flush();

    await _delegateRepository.updateDraftPin(
      SurveyPin(
        id: current.pinId,
        latitude: current.latitude,
        longitude: current.longitude,
        status: SurveyPinStatus.completed,
        buildingId: current.buildingId,
        title: current.building.name.isNotEmpty
            ? current.building.name
            : 'مسح مكتمل',
        address: current.building.realEstateNumber,
      ),
    );

    final updated = current.copyWith(phase: SurveyPhase.completed);
    await _emitAndPersist(updated);
    await flush();
  }

  Future<void> _emitAndPersist(BuildingSurvey survey) async {
    emit(BuildingSurveyLoaded(survey: survey));
    _pendingSurvey = survey;
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 400), () {
      final pending = _pendingSurvey;
      if (pending != null) {
        _localSurveyStore.saveSurvey(pending);
      }
    });
  }

  Future<void> flush() async {
    _persistDebounce?.cancel();
    final pending = _pendingSurvey;
    if (pending != null) {
      await _localSurveyStore.saveSurvey(pending);
    }
  }

  Future<void> _persist(BuildingSurvey survey) async {
    _pendingSurvey = survey;
    await _localSurveyStore.saveSurvey(survey);
  }
}
