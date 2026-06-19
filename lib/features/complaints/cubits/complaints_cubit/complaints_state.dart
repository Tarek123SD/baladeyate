import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:equatable/equatable.dart';

sealed class ComplaintsState extends Equatable {
  const ComplaintsState();

  @override
  List<Object?> get props => [];
}

final class ComplaintsInitial extends ComplaintsState {
  const ComplaintsInitial();
}

final class ComplaintsLoading extends ComplaintsState {
  const ComplaintsLoading();
}

final class ComplaintsLoaded extends ComplaintsState {
  const ComplaintsLoaded({
    required this.complaints,
    this.isSubmitting = false,
  });

  final List<Complaint> complaints;
  final bool isSubmitting;

  int get totalCount => complaints.length;

  int get inProgressCount =>
      complaints.where((complaint) => complaint.isPending).length;

  int get resolvedCount =>
      complaints.where((complaint) => complaint.isResolved).length;

  List<Complaint> filtered(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return complaints.where((complaint) => complaint.isPending).toList();
      case 2:
        return complaints.where((complaint) => complaint.isResolved).toList();
      default:
        return complaints;
    }
  }

  ComplaintsLoaded copyWith({
    List<Complaint>? complaints,
    bool? isSubmitting,
  }) {
    return ComplaintsLoaded(
      complaints: complaints ?? this.complaints,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [complaints, isSubmitting];
}

final class ComplaintsFailure extends ComplaintsState {
  const ComplaintsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ComplaintCreated extends ComplaintsState {
  const ComplaintCreated({required this.complaint});

  final Complaint complaint;

  @override
  List<Object?> get props => [complaint];
}
