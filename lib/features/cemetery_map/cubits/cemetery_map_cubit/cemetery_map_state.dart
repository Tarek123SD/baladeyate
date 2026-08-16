import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:equatable/equatable.dart';

class CemeteryMapState extends Equatable {
  const CemeteryMapState({
    this.graves = const [],
    this.mapUrl,
    this.mapWidth = 2000,
    this.mapHeight = 1500,
    this.isAddingMode = false,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<GraveModel> graves;
  final String? mapUrl;
  final double mapWidth;
  final double mapHeight;
  final bool isAddingMode;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  CemeteryMapState copyWith({
    List<GraveModel>? graves,
    String? mapUrl,
    double? mapWidth,
    double? mapHeight,
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
      mapUrl: mapUrl ?? this.mapUrl,
      mapWidth: mapWidth ?? this.mapWidth,
      mapHeight: mapHeight ?? this.mapHeight,
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
        mapUrl,
        mapWidth,
        mapHeight,
        isAddingMode,
        isLoading,
        isSubmitting,
        errorMessage,
        successMessage,
      ];
}
