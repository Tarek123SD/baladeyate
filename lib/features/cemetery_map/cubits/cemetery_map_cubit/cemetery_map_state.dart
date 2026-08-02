import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:equatable/equatable.dart';

class CemeteryMapState extends Equatable {
  const CemeteryMapState({
    this.graves = const [],
    this.isAddingMode = false,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<GraveModel> graves;
  final bool isAddingMode;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  CemeteryMapState copyWith({
    List<GraveModel>? graves,
    bool? isAddingMode,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CemeteryMapState(
      graves: graves ?? this.graves,
      isAddingMode: isAddingMode ?? this.isAddingMode,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        graves,
        isAddingMode,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
