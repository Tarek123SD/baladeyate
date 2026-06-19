import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  ComplaintsCubit({required ComplaintsRepository complaintsRepository})
      : _complaintsRepository = complaintsRepository,
        super(const ComplaintsInitial());

  final ComplaintsRepository _complaintsRepository;

  Future<void> loadComplaints() async {
    emit(const ComplaintsLoading());
    try {
      final complaints = await _complaintsRepository.getComplaints();
      emit(ComplaintsLoaded(complaints: complaints));
    } catch (error) {
      emit(ComplaintsFailure(message: _messageFromError(error)));
    }
  }

  Future<Complaint?> loadComplaintDetail(int id) async {
    try {
      return await _complaintsRepository.getComplaintById(id);
    } catch (error) {
      emit(ComplaintsFailure(message: _messageFromError(error)));
      return null;
    }
  }

  Future<void> createComplaint({
    required String description,
    required bool isUrgent,
  }) async {
    emit(const ComplaintsLoading());

    try {
      final complaint = await _complaintsRepository.createComplaint(
        description: description,
        priority: isUrgent ? 'urgent' : 'high',
      );
      emit(ComplaintCreated(complaint: complaint));
    } catch (error) {
      emit(ComplaintsFailure(message: _messageFromError(error)));
    }
  }

  Future<bool> updateComplaint({
    required int id,
    required String description,
    required bool isUrgent,
  }) async {
    final current = state;
    if (current is ComplaintsLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    try {
      final updated = await _complaintsRepository.updateComplaint(
        id: id,
        description: description,
        priority: isUrgent ? 'urgent' : 'high',
      );

      if (current is ComplaintsLoaded) {
        final complaints = current.complaints
            .map((item) => item.id == id ? updated : item)
            .toList();
        emit(ComplaintsLoaded(complaints: complaints));
      } else {
        await loadComplaints();
      }
      return true;
    } catch (error) {
      if (current is ComplaintsLoaded) {
        emit(current.copyWith(isSubmitting: false));
      }
      emit(ComplaintsFailure(message: _messageFromError(error)));
      return false;
    }
  }

  Future<bool> deleteComplaint(int id) async {
    final current = state;
    if (current is ComplaintsLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    try {
      await _complaintsRepository.deleteComplaint(id);

      if (current is ComplaintsLoaded) {
        final complaints =
            current.complaints.where((item) => item.id != id).toList();
        emit(ComplaintsLoaded(complaints: complaints));
      } else {
        await loadComplaints();
      }
      return true;
    } catch (error) {
      if (current is ComplaintsLoaded) {
        emit(current.copyWith(isSubmitting: false));
      }
      emit(ComplaintsFailure(message: _messageFromError(error)));
      return false;
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
