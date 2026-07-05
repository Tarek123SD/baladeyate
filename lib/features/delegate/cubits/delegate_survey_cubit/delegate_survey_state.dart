part of 'delegate_survey_cubit.dart';

sealed class DelegateSurveyState extends Equatable {
  const DelegateSurveyState();

  @override
  List<Object?> get props => [];
}

final class DelegateSurveyInitial extends DelegateSurveyState {
  const DelegateSurveyInitial();
}

final class DelegateSurveyEditing extends DelegateSurveyState {
  const DelegateSurveyEditing({required this.draft});

  final SurveyDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class DelegateSurveySubmitting extends DelegateSurveyState {
  const DelegateSurveySubmitting({required this.draft});

  final SurveyDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class DelegateSurveySubmitted extends DelegateSurveyState {
  const DelegateSurveySubmitted({required this.result});

  final SurveySubmissionResult result;

  @override
  List<Object?> get props => [result];
}

final class DelegateSurveyFailure extends DelegateSurveyState {
  const DelegateSurveyFailure({
    required this.draft,
    required this.message,
  });

  final SurveyDraft draft;
  final String message;

  @override
  List<Object?> get props => [draft, message];
}
