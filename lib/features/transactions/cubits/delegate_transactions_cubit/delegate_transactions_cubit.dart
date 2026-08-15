import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/transactions/cubits/delegate_transactions_cubit/delegate_transactions_state.dart';
import 'package:baladeyate/features/transactions/repo/transactions_repository.dart';

class DelegateTransactionsCubit extends Cubit<DelegateTransactionsState> {
  final TransactionsRepository _repository;

  DelegateTransactionsCubit({required TransactionsRepository repository})
      : _repository = repository,
        super(DelegateTransactionsInitial());

  Future<void> fetch() async {
    emit(DelegateTransactionsLoading());
    try {
      final items = await _repository.getDelegateTransactions();
      emit(DelegateTransactionsLoaded(items));
    } catch (e) {
      emit(DelegateTransactionsError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل جلب معاملات المعاينة',
        ),
      ));
    }
  }

  Future<bool> submitInspection({
    required int transactionId,
    required String notes,
  }) async {
    try {
      await _repository.submitInspection(
        transactionId: transactionId,
        inspectionNotes: notes,
      );
      await fetch();
      return true;
    } catch (e) {
      emit(DelegateTransactionsError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل تقديم تقرير المعاينة',
        ),
      ));
      return false;
    }
  }
}
