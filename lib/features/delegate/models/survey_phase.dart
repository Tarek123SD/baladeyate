enum SurveyPhase {
  buildingPending,
  floorsInProgress,
  completed;

  static SurveyPhase fromString(String? value) {
    switch (value) {
      case 'floors_in_progress':
        return SurveyPhase.floorsInProgress;
      case 'completed':
        return SurveyPhase.completed;
      case 'building_pending':
      default:
        return SurveyPhase.buildingPending;
    }
  }

  String get storageValue {
    switch (this) {
      case SurveyPhase.buildingPending:
        return 'building_pending';
      case SurveyPhase.floorsInProgress:
        return 'floors_in_progress';
      case SurveyPhase.completed:
        return 'completed';
    }
  }
}
