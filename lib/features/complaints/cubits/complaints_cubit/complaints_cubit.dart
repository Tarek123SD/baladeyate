import 'dart:io';

import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintsCubit extends Cubit<ComplaintsState> {
  ComplaintsCubit({required ComplaintsRepository complaintsRepository})
      : _complaintsRepository = complaintsRepository,
        super(const ComplaintsInitial());

  final ComplaintsRepository _complaintsRepository;

  /// Bumped after a complaint is created so other cubit instances (track tab)
  /// can reload even though each screen owns its own factory cubit.
  static final ValueNotifier<int> listVersion = ValueNotifier(0);

  static void markListStale() => listVersion.value++;

  Future<void> loadComplaints() async {
    final previousFilter = switch (state) {
      ComplaintsLoaded(:final selectedFilterIndex) => selectedFilterIndex,
      _ => 0,
    };
    final previousUrgent = switch (state) {
      ComplaintsLoaded(:final isUrgent) => isUrgent,
      _ => false,
    };
    if (state is! ComplaintsLoaded) {
      emit(const ComplaintsLoading());
    }
    try {
      final complaints = await _complaintsRepository.getComplaints();
      emit(ComplaintsLoaded(
        complaints: complaints,
        selectedFilterIndex: previousFilter,
        isUrgent: previousUrgent,
      ));
    } catch (error) {
      emit(ComplaintsFailure(message: _messageFromError(error)));
    }
  }

  void setFilter(int index) {
    final current = state;
    if (current is ComplaintsLoaded) {
      emit(current.copyWith(selectedFilterIndex: index));
    }
  }

  void setIsUrgent(bool value) {
    final current = state;
    if (current is ComplaintsLoaded) {
      emit(current.copyWith(isUrgent: value));
    } else {
      emit(ComplaintsLoaded(complaints: const [], isUrgent: value));
    }
  }

  bool get isUrgent {
    final current = state;
    if (current is ComplaintsLoaded) return current.isUrgent;
    return false;
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
    List<File> attachments = const [],
  }) async {
    emit(const ComplaintsLoading());

    try {
      final complaint = await _complaintsRepository.createComplaint(
        description: description,
        priority: isUrgent ? 'urgent' : 'medium',
        attachments: attachments,
      );
      markListStale();
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
        priority: isUrgent ? 'urgent' : 'medium',
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

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'حدث خطأ غير متوقع',
    );
  }
}
