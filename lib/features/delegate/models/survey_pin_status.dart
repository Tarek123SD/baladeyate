enum SurveyPinStatus {
  inProgress,
  completed,
  assigned;

  static SurveyPinStatus fromString(String? value) {
    switch (value) {
      case 'completed':
        return SurveyPinStatus.completed;
      case 'assigned':
        return SurveyPinStatus.assigned;
      case 'in_progress':
      default:
        return SurveyPinStatus.inProgress;
    }
  }

  String get storageValue {
    switch (this) {
      case SurveyPinStatus.completed:
        return 'completed';
      case SurveyPinStatus.assigned:
        return 'assigned';
      case SurveyPinStatus.inProgress:
        return 'in_progress';
    }
  }
}
