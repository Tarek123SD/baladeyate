import 'package:equatable/equatable.dart';
import '../../models/transaction_model.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  final int selectedFilterIndex;
  final String? selectedTypeFilter;

  const TransactionsLoaded({
    required this.transactions,
    this.selectedFilterIndex = 0,
    this.selectedTypeFilter,
  });

  @override
  List<Object?> get props => [transactions, selectedFilterIndex, selectedTypeFilter];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
