import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:equatable/equatable.dart';

class ComplaintDetailState extends Equatable {
  const ComplaintDetailState({
    required this.complaint,
    this.isEditing = false,
    this.isBusy = false,
    this.isUrgent = false,
    String? subject,
    String? details,
    this.attachmentCount = 0,
    this.addressLine,
    this.locationLine,
  })  : _subject = subject,
        _details = details;

  final Complaint complaint;
  final bool isEditing;
  final bool isBusy;
  final bool isUrgent;
  final String? _subject;
  final String? _details;
  final int attachmentCount;
  final String? addressLine;
  final String? locationLine;

  String get subject {
    final draft = _subject;
    if (draft != null) return draft;
    return parseComplaintDescription(complaint.description).subject;
  }

  String get details {
    final draft = _details;
    if (draft != null) return draft;
    return parseComplaintDescription(complaint.description).details;
  }

  ComplaintDetailState copyWith({
    Complaint? complaint,
    bool? isEditing,
    bool? isBusy,
    bool? isUrgent,
    String? subject,
    String? details,
    int? attachmentCount,
    String? addressLine,
    String? locationLine,
  }) {
    return ComplaintDetailState(
      complaint: complaint ?? this.complaint,
      isEditing: isEditing ?? this.isEditing,
      isBusy: isBusy ?? this.isBusy,
      isUrgent: isUrgent ?? this.isUrgent,
      subject: subject ?? _subject,
      details: details ?? _details,
      attachmentCount: attachmentCount ?? this.attachmentCount,
      addressLine: addressLine ?? this.addressLine,
      locationLine: locationLine ?? this.locationLine,
    );
  }

  @override
  List<Object?> get props => [
        complaint,
        isEditing,
        isBusy,
        isUrgent,
        _subject,
        _details,
        attachmentCount,
        addressLine,
        locationLine,
      ];
}
