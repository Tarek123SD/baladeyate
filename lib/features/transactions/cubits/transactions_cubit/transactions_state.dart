import 'package:equatable/equatable.dart';
import 'package:baladeyate/features/transactions/models/transaction_model.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  final int selectedTypeFilterIndex;
  final int selectedStatusFilterIndex;
  final String? selectedTypeFilter;
  final String? selectedStatusFilter;
  final List<({String label, String? typeKey})> typeOptions;

  const TransactionsLoaded({
    required this.transactions,
    this.selectedTypeFilterIndex = 0,
    this.selectedStatusFilterIndex = 0,
    this.selectedTypeFilter,
    this.selectedStatusFilter,
    this.typeOptions = const [],
  });

  @override
  List<Object?> get props => [
        transactions,
        selectedTypeFilterIndex,
        selectedStatusFilterIndex,
        selectedTypeFilter,
        selectedStatusFilter,
        typeOptions,
      ];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
