import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintDetailCubit extends Cubit<ComplaintDetailState> {
  ComplaintDetailCubit({
    required Complaint complaint,
    required ComplaintsCubit complaintsCubit,
  })  : _complaintsCubit = complaintsCubit,
        super(
          ComplaintDetailState(
            complaint: complaint,
            isUrgent: complaint.priority == 'urgent',
            description: complaint.description,
          ),
        );

  final ComplaintsCubit _complaintsCubit;

  Future<void> loadDetail() async {
    emit(state.copyWith(isBusy: true));
    final detail =
        await _complaintsCubit.loadComplaintDetail(state.complaint.id);
    if (detail != null) {
      emit(state.copyWith(
        complaint: detail,
        description: detail.description,
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
    emit(state.copyWith(
      isEditing: false,
      description: state.complaint.description,
      isUrgent: state.complaint.priority == 'urgent',
    ));
  }

  void setIsUrgent(bool value) {
    emit(state.copyWith(isUrgent: value));
  }

  void setDescription(String value) {
    emit(state.copyWith(description: value));
  }

  Future<bool> saveChanges() async {
    emit(state.copyWith(isBusy: true));
    final success = await _complaintsCubit.updateComplaint(
      id: state.complaint.id,
      description: state.description.trim(),
      isUrgent: state.isUrgent,
    );
    if (success) {
      emit(state.copyWith(isBusy: false, isEditing: false));
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
