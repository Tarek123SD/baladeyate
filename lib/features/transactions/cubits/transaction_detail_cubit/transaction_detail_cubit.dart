import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/transactions/cubits/transaction_detail_cubit/transaction_detail_state.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';

class TransactionDetailCubit extends Cubit<TransactionDetailState> {
  final TransactionsRepository _repository;
  final int transactionId;

  TransactionDetailCubit({
    required TransactionsRepository repository,
    required this.transactionId,
  })  : _repository = repository,
        super(TransactionDetailInitial());

  Future<void> load() async {
    emit(TransactionDetailLoading());
    try {
      final transaction = await _repository.getTransactionById(transactionId);
      emit(TransactionDetailLoaded(transaction: transaction));
    } catch (e) {
      emit(TransactionDetailError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل جلب تفاصيل المعاملة',
        ),
      ));
    }
  }

  Future<void> pickFiles() async {
    final current = state;
    if (current is! TransactionDetailLoaded) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );
      if (result == null || result.files.isEmpty) return;

      emit(current.copyWith(
        pendingFiles: [...current.pendingFiles, ...result.files],
      ));
    } catch (_) {}
  }

  void removePendingFile(int index) {
    final current = state;
    if (current is! TransactionDetailLoaded) return;
    if (index < 0 || index >= current.pendingFiles.length) return;

    final updated = List<PlatformFile>.from(current.pendingFiles)
      ..removeAt(index);
    emit(current.copyWith(pendingFiles: updated));
  }

  /// Returns `null` on success, or an error message.
  Future<String?> uploadDocuments() async {
    final current = state;
    if (current is! TransactionDetailLoaded) return 'حالة غير صالحة';
    if (current.pendingFiles.isEmpty) return 'يرجى إرفاق ملف واحد على الأقل';

    emit(current.copyWith(isUploading: true));
    try {
      final updated = await _repository.uploadDocuments(
        transactionId: transactionId,
        attachments: current.pendingFiles,
      );
      emit(TransactionDetailLoaded(transaction: updated));
      return null;
    } catch (e) {
      emit(current.copyWith(isUploading: false));
      return ApiResponseParser.toUserMessage(e, fallback: 'فشل رفع الوثائق');
    }
  }

  /// Returns `null` on success, or an error message.
  Future<String?> cancel() async {
    final current = state;
    if (current is! TransactionDetailLoaded) return 'حالة غير صالحة';

    emit(current.copyWith(isCancelling: true));
    try {
      final updated = await _repository.cancelTransaction(transactionId);
      emit(TransactionDetailLoaded(transaction: updated));
      return null;
    } catch (e) {
      emit(current.copyWith(isCancelling: false));
      return ApiResponseParser.toUserMessage(e, fallback: 'فشل إلغاء المعاملة');
    }
  }
}
