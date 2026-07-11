part of 'building_survey_cubit.dart';

sealed class BuildingSurveyState extends Equatable {
  const BuildingSurveyState();

  @override
  List<Object?> get props => [];
}

final class BuildingSurveyInitial extends BuildingSurveyState {
  const BuildingSurveyInitial();
}

final class BuildingSurveyLoaded extends BuildingSurveyState {
  const BuildingSurveyLoaded({required this.survey});

  final BuildingSurvey survey;

  @override
  List<Object?> get props => [survey];
}

final class BuildingSurveySaving extends BuildingSurveyState {
  const BuildingSurveySaving({required this.survey});

  final BuildingSurvey survey;

  @override
  List<Object?> get props => [survey];
}

final class BuildingSurveyFailure extends BuildingSurveyState {
  const BuildingSurveyFailure({
    required this.survey,
    required this.message,
  });

  final BuildingSurvey survey;
  final String message;

  @override
  List<Object?> get props => [survey, message];
}
