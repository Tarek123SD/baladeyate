import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  ComplaintDetailCubit({
    required Complaint complaint,
    required ComplaintsCubit complaintsCubit,
  })  : _complaintsCubit = complaintsCubit,
        super(_initialState(complaint));

  final ComplaintsCubit _complaintsCubit;

  static ComplaintDetailState _initialState(Complaint complaint) {
    final parts = parseComplaintDescription(complaint.description);
    return ComplaintDetailState(
      complaint: complaint,
      isUrgent: complaint.priority == 'urgent',
      subject: parts.subject,
      details: parts.details,
      attachmentCount: parts.attachmentCount,
      addressLine: parts.addressLine,
      locationLine: parts.locationLine,
    );
  }

  Future<void> loadDetail() async {
    emit(state.copyWith(isBusy: true));
    final detail =
        await _complaintsCubit.loadComplaintDetail(state.complaint.id);
    if (detail != null) {
      final parts = parseComplaintDescription(detail.description);
      emit(state.copyWith(
        complaint: detail,
        subject: parts.subject,
        details: parts.details,
        attachmentCount: parts.attachmentCount,
        addressLine: parts.addressLine,
        locationLine: parts.locationLine,
        isUrgent: detail.priority == 'urgent',
        isBusy: false,
      ));
    } else {
      emit(state.copyWith(isBusy: false));
    }
  }

  void startEditing() {
    emit(state.copyWith(isEditing: true));
  }

  void cancelEditing() {
    final parts = parseComplaintDescription(state.complaint.description);
    emit(state.copyWith(
      isEditing: false,
      subject: parts.subject,
      details: parts.details,
      attachmentCount: parts.attachmentCount,
      addressLine: parts.addressLine,
      locationLine: parts.locationLine,
      isUrgent: state.complaint.priority == 'urgent',
    ));
  }

  void setIsUrgent(bool value) {
    emit(state.copyWith(isUrgent: value));
  }

  void setSubject(String value) {
    emit(state.copyWith(subject: value));
  }

  void setDetails(String value) {
    emit(state.copyWith(details: value));
  }

  Future<bool> saveChanges({
    required int attachmentCount,
  }) async {
    emit(state.copyWith(isBusy: true));
    final description = composeComplaintDescription(
      subject: state.subject.trim(),
      details: state.details.trim(),
      attachmentCount: attachmentCount,
      addressLine: state.addressLine,
      locationLine: state.locationLine,
    );

    final success = await _complaintsCubit.updateComplaint(
      id: state.complaint.id,
      description: description,
      isUrgent: state.isUrgent,
    );
    if (success) {
      emit(state.copyWith(isBusy: false, isEditing: false));
      await loadDetail();
    } else {
      emit(state.copyWith(isBusy: false));
    }
    return success;
  }

  Future<bool> deleteComplaint() async {
    emit(state.copyWith(isBusy: true));
    final success = await _complaintsCubit.deleteComplaint(state.complaint.id);
    if (!success) {
      emit(state.copyWith(isBusy: false));
    }
    return success;
  }
}
