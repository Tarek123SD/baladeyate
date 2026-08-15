import 'package:equatable/equatable.dart';
import 'package:baladeyate/features/transactions/models/transaction_model.dart';

abstract class DelegateTransactionsState extends Equatable {
  const DelegateTransactionsState();

  @override
  List<Object?> get props => [];
}

class DelegateTransactionsInitial extends DelegateTransactionsState {}

class DelegateTransactionsLoading extends DelegateTransactionsState {}

class DelegateTransactionsLoaded extends DelegateTransactionsState {
  final List<TransactionModel> transactions;

  const DelegateTransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class DelegateTransactionsError extends DelegateTransactionsState {
  final String message;

  const DelegateTransactionsError(this.message);

  @override
  List<Object?> get props => [message];
}
