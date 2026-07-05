import 'package:baladeyate/features/delegate/models/survey_draft.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_resident.dart';
import 'package:baladeyate/features/delegate/models/survey_submission_result.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'delegate_survey_state.dart';

class DelegateSurveyCubit extends Cubit<DelegateSurveyState> {
  DelegateSurveyCubit({required DelegateRepository delegateRepository})
      : _delegateRepository = delegateRepository,
        super(const DelegateSurveyInitial());

  final DelegateRepository _delegateRepository;

  void initSurvey(SurveyLocation location) {
    emit(
      DelegateSurveyEditing(
        draft: SurveyDraft(
          pinId: location.pinId,
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      ),
    );
  }

  void updateDraft(SurveyDraft draft) {
    final current = state;
    if (current is DelegateSurveyEditing) {
      emit(DelegateSurveyEditing(draft: draft));
    }
  }

  void updateBuilding({
    String? buildingNumber,
    String? buildingName,
    String? buildingAddress,
    String? floorCount,
    String? buildingType,
  }) {
    _mutateDraft(
      (draft) => draft.copyWith(
        buildingNumber: buildingNumber,
        buildingName: buildingName,
        buildingAddress: buildingAddress,
        floorCount: floorCount,
        buildingType: buildingType,
      ),
    );
  }

  void updateFloor({
    String? floorNumber,
    String? floorName,
    String? apartmentCount,
    String? floorPlanNumber,
  }) {
    _mutateDraft(
      (draft) => draft.copyWith(
        floorNumber: floorNumber,
        floorName: floorName,
        apartmentCount: apartmentCount,
        floorPlanNumber: floorPlanNumber,
      ),
    );
  }

  void updateApartment({
    String? apartmentNumber,
    String? apartmentType,
    String? occupancyStatus,
    int? roomCount,
  }) {
    _mutateDraft(
      (draft) => draft.copyWith(
        apartmentNumber: apartmentNumber,
        apartmentType: apartmentType,
        occupancyStatus: occupancyStatus,
        roomCount: roomCount,
      ),
    );
  }

  void updateFamily({
    String? residentCount,
    String? phone,
    List<SurveyResident>? residents,
    bool? isDataVerified,
  }) {
    _mutateDraft(
      (draft) => draft.copyWith(
        residentCount: residentCount,
        phone: phone,
        residents: residents,
        isDataVerified: isDataVerified,
      ),
    );
  }

  Future<SurveySubmissionResult?> submitSurvey() async {
    final current = state;
    if (current is! DelegateSurveyEditing) return null;

    emit(DelegateSurveySubmitting(draft: current.draft));
    try {
      final result = await _delegateRepository.submitSurvey(current.draft);
      emit(DelegateSurveySubmitted(result: result));
      return result;
    } catch (error) {
      emit(
        DelegateSurveyFailure(
          draft: current.draft,
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
      return null;
    }
  }

  void _mutateDraft(SurveyDraft Function(SurveyDraft draft) transform) {
    final current = state;
    if (current is DelegateSurveyEditing) {
      emit(DelegateSurveyEditing(draft: transform(current.draft)));
    } else if (current is DelegateSurveyFailure) {
      emit(DelegateSurveyEditing(draft: transform(current.draft)));
    }
  }
}
