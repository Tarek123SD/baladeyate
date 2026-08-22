import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/transactions/cubits/submit_transaction_cubit/submit_transaction_state.dart';
import 'package:baladeyate/features/transactions/models/transaction_document_catalog.dart';
import 'package:baladeyate/features/transactions/models/transaction_type_config.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';

class SubmitTransactionCubit extends Cubit<SubmitTransactionState> {
  final TransactionsRepository _transactionsRepository;

  SubmitTransactionCubit({
    required TransactionsRepository transactionsRepository,
  })  : _transactionsRepository = transactionsRepository,
        super(const SubmitTransactionInitial());

  /// Getter for attached files (for backward compatibility).
  List<PlatformFile> get attachments => state.attachedFiles;

  Future<void> loadTransactionTypes() async {
    emit(SubmitTransactionInitial(
      selectedType: state.selectedType,
      attachedFiles: state.attachedFiles,
      formData: state.formData,
      types: state.types,
      isLoadingTypes: true,
    ));

    try {
      final types = await _transactionsRepository.getTransactionTypes();
      TransactionDocumentCatalog.replaceRemote(
        types.map((type) => type.guide).toList(),
      );
      emit(SubmitTransactionInitial(
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
        types: types,
      ));
    } catch (error) {
      emit(SubmitTransactionFailure(
        error: ApiResponseParser.toUserMessage(
          error,
          fallback: 'تعذر تحميل أنواع المعاملات',
        ),
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
        types: state.types,
      ));
    }
  }

  /// Changes the selected transaction type and clears old form data.
  void changeTransactionType(String type) {
    emit(SubmitTransactionInitial(
      selectedType: type,
      attachedFiles: state.attachedFiles,
      formData: const {},
      types: state.types,
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
      types: state.types,
    ));
  }

  /// Picks multiple files (PDF, JPG, PNG) and appends them to the current list.
  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final updatedFiles = List<PlatformFile>.from(state.attachedFiles)
          ..addAll(result.files);
        emit(SubmitTransactionInitial(
          selectedType: state.selectedType,
          attachedFiles: updatedFiles,
          formData: state.formData,
          types: state.types,
        ));
      }
    } catch (_) {
      emit(SubmitTransactionFailure(
        error: 'تعذر اختيار الملفات. يرجى المحاولة مرة أخرى',
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
        types: state.types,
      ));
    }
  }

  /// Removes a file from the attachment list at [index].
  void removeFile(int index) {
    if (index >= 0 && index < state.attachedFiles.length) {
      final updatedFiles = List<PlatformFile>.from(state.attachedFiles)
        ..removeAt(index);
      emit(SubmitTransactionInitial(
        selectedType: state.selectedType,
        attachedFiles: updatedFiles,
        formData: state.formData,
        types: state.types,
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
        types: state.types,
      ));
      return;
    }

    TransactionTypeConfig? selected;
    for (final item in state.types) {
      if (item.type == targetType) {
        selected = item;
        break;
      }
    }
    final minRequired = selected?.minimumRequiredAttachments ??
        TransactionDocumentCatalog.minimumRequiredAttachments(targetType);
    if (state.attachedFiles.length < minRequired) {
      emit(SubmitTransactionFailure(
        error:
            'يرجى إرفاق $minRequired ملفات إلزامية على الأقل حسب قائمة الوثائق المطلوبة',
        selectedType: state.selectedType,
        attachedFiles: state.attachedFiles,
        formData: state.formData,
        types: state.types,
      ));
      return;
    }

    emit(SubmitTransactionLoading(
      selectedType: state.selectedType,
      attachedFiles: state.attachedFiles,
      formData: state.formData,
      types: state.types,
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
        types: state.types,
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
        types: state.types,
      ));
    }
  }

  /// Clears selected files and resets state.
  void reset() {
    emit(SubmitTransactionInitial(types: state.types));
  }
}
