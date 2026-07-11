import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:equatable/equatable.dart';

class ComplaintDetailState extends Equatable {
  const ComplaintDetailState({
    required this.complaint,
    this.isEditing = false,
    this.isBusy = false,
    this.isUrgent = false,
    this.description = '',
  });

  final Complaint complaint;
  final bool isEditing;
  final bool isBusy;
  final bool isUrgent;
  final String description;

  ComplaintDetailState copyWith({
    Complaint? complaint,
    bool? isEditing,
    bool? isBusy,
    bool? isUrgent,
    String? description,
  }) {
    return ComplaintDetailState(
      complaint: complaint ?? this.complaint,
      isEditing: isEditing ?? this.isEditing,
      isBusy: isBusy ?? this.isBusy,
      isUrgent: isUrgent ?? this.isUrgent,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        complaint,
        isEditing,
        isBusy,
        isUrgent,
        description,
      ];
}
