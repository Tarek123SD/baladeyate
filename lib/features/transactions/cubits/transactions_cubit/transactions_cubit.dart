import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import '../../repo/transactions_repository.dart';
import 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  final TransactionsRepository _transactionsRepository;

  String? _typeFilter;
  String? _statusFilter;
  int _typeFilterIndex = 0;
  int _statusFilterIndex = 0;

  TransactionsCubit({required TransactionsRepository transactionsRepository})
      : _transactionsRepository = transactionsRepository,
        super(TransactionsInitial());

  Future<void> fetchTransactions({
    String? type,
    String? status,
    int? typeFilterIndex,
    int? statusFilterIndex,
  }) async {
    if (typeFilterIndex != null) {
      _typeFilterIndex = typeFilterIndex;
      _typeFilter = type;
    }
    if (statusFilterIndex != null) {
      _statusFilterIndex = statusFilterIndex;
      _statusFilter = status;
    }

    // Keep previous filters when only one dimension is refreshed.
    final effectiveType = typeFilterIndex != null ? type : _typeFilter;
    final effectiveStatus =
        statusFilterIndex != null ? status : _statusFilter;

    if (typeFilterIndex == null && statusFilterIndex == null) {
      // Full refresh (pull-to-refresh / post-frame) keeps current filters.
    }

    emit(TransactionsLoading());
    try {
      final transactions = await _transactionsRepository.getTransactions(
        type: effectiveType,
        status: effectiveStatus,
      );
      emit(TransactionsLoaded(
        transactions: transactions,
        selectedTypeFilterIndex: _typeFilterIndex,
        selectedStatusFilterIndex: _statusFilterIndex,
        selectedTypeFilter: _typeFilter,
        selectedStatusFilter: _statusFilter,
      ));
    } catch (e) {
      emit(TransactionsError(
        ApiResponseParser.toUserMessage(
          e,
          fallback: 'فشل جلب قائمة المعاملات',
        ),
      ));
    }
  }

  Future<void> applyTypeFilter({
    required int index,
    String? type,
  }) {
    return fetchTransactions(
      type: type,
      typeFilterIndex: index,
      status: _statusFilter,
      statusFilterIndex: _statusFilterIndex,
    );
  }

  Future<void> applyStatusFilter({
    required int index,
    String? status,
  }) {
    return fetchTransactions(
      status: status,
      statusFilterIndex: index,
      type: _typeFilter,
      typeFilterIndex: _typeFilterIndex,
    );
  }
}
