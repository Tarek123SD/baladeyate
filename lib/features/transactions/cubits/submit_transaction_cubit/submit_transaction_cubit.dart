import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/features/transactions/cubits/submit_transaction_cubit/submit_transaction_state.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';

class SubmitTransactionCubit extends Cubit<SubmitTransactionState> {
  final TransactionsRepository _transactionsRepository;
  final List<PlatformFile> attachments = [];

  SubmitTransactionCubit({
    required TransactionsRepository transactionsRepository,
  })  : _transactionsRepository = transactionsRepository,
        super(const SubmitTransactionInitial());

  /// Picks multiple files (PDF, JPG, PNG) and updates the attachment list.
  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null) {
        attachments.addAll(result.files);
        // Emit initial state to trigger a UI update/rebuild
        emit(const SubmitTransactionInitial());
      }
    } catch (e) {
      emit(SubmitTransactionFailure(error: 'فشل في اختيار الملفات: $e'));
    }
  }

  /// Removes a file from the attachment list at [index].
  void removeFile(int index) {
    if (index >= 0 && index < attachments.length) {
      attachments.removeAt(index);
      // Emit initial state to trigger a UI update/rebuild
      emit(const SubmitTransactionInitial());
    }
  }

  /// Submits the transaction data to the backend.
  Future<void> submitTransaction({
    required String type,
    required Map<String, dynamic> formData,
    int? buildingId,
  }) async {
    emit(const SubmitTransactionLoading());

    try {
      final transactionNumber = await _transactionsRepository.submitTransaction(
        type: type,
        formData: formData,
        buildingId: buildingId,
        attachments: attachments,
      );

      emit(SubmitTransactionSuccess(transactionNumber: transactionNumber));
    } catch (error) {
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      emit(SubmitTransactionFailure(error: errorMessage));
    }
  }

  /// Clears selected files and resets state.
  void reset() {
    attachments.clear();
    emit(const SubmitTransactionInitial());
  }
}
