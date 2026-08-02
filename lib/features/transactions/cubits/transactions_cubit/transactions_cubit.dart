import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repo/transactions_repository.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository _transactionsRepository;

  TransactionsCubit({required TransactionsRepository transactionsRepository})
      : _transactionsRepository = transactionsRepository,
        super(TransactionsInitial());

  /// Fetches transactions from backend endpoint (GET /api/v1/transactions).
  Future<void> fetchTransactions({
    String? type,
    String? status,
    int filterIndex = 0,
  }) async {
    emit(TransactionsLoading());
    try {
      final transactions = await _transactionsRepository.getTransactions(
        type: type,
        status: status,
      );
      emit(TransactionsLoaded(
        transactions: transactions,
        selectedFilterIndex: filterIndex,
        selectedTypeFilter: type,
      ));
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      emit(TransactionsError(cleanMessage));
    }
  }
}
