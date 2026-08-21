import 'dart:io';

import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaint_detail_cubit/delegate_complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DelegateComplaintDetailCubit extends Cubit<DelegateComplaintDetailState> {
  DelegateComplaintDetailCubit({
    required ComplaintsRepository repository,
    required int complaintId,
    Complaint? initialComplaint,
  })  : _repository = repository,
        super(
          DelegateComplaintDetailState(
            complaintId: complaintId,
            complaint: initialComplaint,
            isLoading: initialComplaint == null,
          ),
        );

  final ComplaintsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(isLoading: state.complaint == null, clearError: true));
    try {
      final detail =
          await _repository.getDelegateComplaintById(state.complaintId);
      emit(state.copyWith(
        complaint: detail,
        isLoading: false,
        clearError: true,
      ));
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: ApiResponseParser.toUserMessage(
          error,
          fallback: 'فشل تحميل تفاصيل الشكوى',
        ),
      ));
    }
  }

  Future<bool> submitFieldReport({
    required String notes,
    required String outcome,
    List<File> attachments = const [],
  }) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final updated = await _repository.submitFieldReport(
        complaintId: state.complaintId,
        fieldNotes: notes,
        fieldOutcome: outcome,
        attachments: attachments,
      );
      emit(state.copyWith(
        complaint: updated,
        isSubmitting: false,
        clearError: true,
      ));
      return true;
    } catch (error) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: ApiResponseParser.toUserMessage(
          error,
          fallback: 'فشل تقديم التقرير الميداني',
        ),
      ));
      return false;
    }
  }
}
