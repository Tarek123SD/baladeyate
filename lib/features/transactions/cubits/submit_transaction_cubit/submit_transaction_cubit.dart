import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/transactions/cubits/submit_transaction_cubit/submit_transaction_state.dart';
import 'package:baladeyate/features/transactions/models/transaction_document_catalog.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';

class SubmitTransactionCubit extends Cubit<SubmitTransactionState> {
  final TransactionsRepository _transactionsRepository;

  SubmitTransactionCubit({
    required TransactionsRepository transactionsRepository,
  })  : _transactionsRepository = transactionsRepository,
        super(const SubmitTransactionInitial());

  /// Getter for attached files (for backward compatibility).
  List<PlatformFile> get attachments => state.attachedFiles;

  /// Changes the selected transaction type and clears old form data.
  void changeTransactionType(String type) {
    emit(SubmitTransactionInitial(
      selectedType: type,
      attachedFiles: state.attachedFiles,
      formData: const {},
    ));
  }

  /// Updates a specific field in the form data map.
  void updateFormField(String key, dynamic value) {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    if (value == null || (value is String && value.trim().isEmpty)) {
      updatedFormData.remove(key);
    } else {
      updatedFormData[key] = value;
    }
    emit(SubmitTransactionInitial(
      selectedType: state.selectedType,
      attachedFiles: state.attachedFiles,
      formData: updatedFormData,
    ));
  }

  /// Picks multiple files (PDF, JPG, PNG) and appends them to the current list.
  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final updatedFiles = List<PlatformFile>.from(state.attachedFiles)..addAll(result.files);
        emit(SubmitTransactionInitial(
          selectedType: state.selectedType,
          attachedFiles: updatedFiles,
          formData: state.formData,
        ));
      }
    } catch (_) {
      emit(SubmitTransactionFailure(
        error: 'تعذر اختيار الملفات. يرجى المحاولة مرة أخرى',
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
      ));
    }
  }

  /// Removes a file from the attachment list at [index].
  void removeFile(int index) {
    if (index >= 0 && index < state.attachedFiles.length) {
      final updatedFiles = List<PlatformFile>.from(state.attachedFiles)..removeAt(index);
      emit(SubmitTransactionInitial(
        selectedType: state.selectedType,
        attachedFiles: updatedFiles,
        formData: state.formData,
      ));
    }
  }

  /// Submits the transaction data to the backend.
  Future<void> submitTransaction({
    String? type,
    Map<String, dynamic>? formData,
    int? buildingId,
  }) async {
    final targetType = type ?? state.selectedType;
    final targetFormData = formData ?? state.formData;

    if (targetType == null || targetType.isEmpty) {
      emit(SubmitTransactionFailure(
        error: 'يرجى اختيار نوع المعاملة أولاً',
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
      ));
      return;
    }

    final minRequired =
        TransactionDocumentCatalog.minimumRequiredAttachments(targetType);
    if (state.attachedFiles.length < minRequired) {
      emit(SubmitTransactionFailure(
        error:
            'يرجى إرفاق $minRequired ملفات إلزامية على الأقل حسب قائمة الوثائق المطلوبة',
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
      ));
      return;
    }

    emit(SubmitTransactionLoading(
      selectedType: state.selectedType,
      attachedFiles: state.attachedFiles,
      formData: state.formData,
    ));

    try {
      final transactionNumber = await _transactionsRepository.submitTransaction(
        type: targetType,
        formData: targetFormData,
        buildingId: buildingId,
        attachments: state.attachedFiles,
      );

      emit(SubmitTransactionSuccess(
        transactionNumber: transactionNumber,
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
      ));
    } catch (error) {
      emit(SubmitTransactionFailure(
        error: ApiResponseParser.toUserMessage(
          error,
          fallback: 'فشل تقديم المعاملة',
        ),
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
      ));
    }
  }

  /// Clears selected files and resets state.
  void reset() {
    emit(const SubmitTransactionInitial());
  }
}
