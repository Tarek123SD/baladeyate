/// Route extra for delegate survey navigation between existing screens.
class SurveyNavigationContext {
  const SurveyNavigationContext({
    required this.pinId,
    this.floorLocalId,
    this.isNewFloor = false,
    this.apartmentsCount = 0,
  });

  final String pinId;
  final String? floorLocalId;
  final bool isNewFloor;
  final int apartmentsCount;
}
