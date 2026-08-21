import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaints_cubit/delegate_complaints_state.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';

class DelegateComplaintsCubit extends Cubit<DelegateComplaintsState> {
  DelegateComplaintsCubit({required ComplaintsRepository repository})
      : _repository = repository,
        super(DelegateComplaintsInitial());

  final ComplaintsRepository _repository;

  Future<void> fetch() async {
    emit(DelegateComplaintsLoading());
    try {
      final items = await _repository.getDelegateComplaints();
      emit(DelegateComplaintsLoaded(items));
    } catch (e) {
      emit(DelegateComplaintsError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل جلب الشكاوى الميدانية',
        ),
      ));
    }
  }

  Future<bool> submitFieldReport({
    required int complaintId,
    required String notes,
    required String outcome,
    List<File> attachments = const [],
  }) async {
    try {
      await _repository.submitFieldReport(
        complaintId: complaintId,
        fieldNotes: notes,
        fieldOutcome: outcome,
        attachments: attachments,
      );
      await fetch();
      return true;
    } catch (e) {
      emit(DelegateComplaintsError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل تقديم التقرير الميداني',
        ),
      ));
      return false;
    }
  }
}
