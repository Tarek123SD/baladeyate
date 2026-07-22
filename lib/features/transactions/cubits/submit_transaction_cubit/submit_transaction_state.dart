import 'package:equatable/equatable.dart';

sealed class SubmitTransactionState extends Equatable {
  const SubmitTransactionState();

  @override
  List<Object?> get props => [];
}

final class SubmitTransactionInitial extends SubmitTransactionState {
  const SubmitTransactionInitial();
}

final class SubmitTransactionLoading extends SubmitTransactionState {
  const SubmitTransactionLoading();
}

final class SubmitTransactionSuccess extends SubmitTransactionState {
  const SubmitTransactionSuccess({required this.transactionNumber});

  final String transactionNumber;

  @override
  List<Object?> get props => [transactionNumber];
}

final class SubmitTransactionFailure extends SubmitTransactionState {
  const SubmitTransactionFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
