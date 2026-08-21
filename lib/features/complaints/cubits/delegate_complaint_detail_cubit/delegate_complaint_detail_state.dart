import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:equatable/equatable.dart';

class DelegateComplaintDetailState extends Equatable {
  const DelegateComplaintDetailState({
    required this.complaintId,
    this.complaint,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final int complaintId;
  final Complaint? complaint;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  DelegateComplaintDetailState copyWith({
    Complaint? complaint,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DelegateComplaintDetailState(
      complaintId: complaintId,
      complaint: complaint ?? this.complaint,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [complaintId, complaint, isLoading, isSubmitting, errorMessage];
}
