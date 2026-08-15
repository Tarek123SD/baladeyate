import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baladeyate/features/transactions/models/transaction_model.dart';

abstract class TransactionDetailState extends Equatable {
  const TransactionDetailState();

  @override
  List<Object?> get props => [];
}

class TransactionDetailInitial extends TransactionDetailState {}

class TransactionDetailLoading extends TransactionDetailState {}

class TransactionDetailLoaded extends TransactionDetailState {
  final TransactionModel transaction;
  final List<PlatformFile> pendingFiles;
  final bool isUploading;
  final bool isCancelling;

  const TransactionDetailLoaded({
    required this.transaction,
    this.pendingFiles = const [],
    this.isUploading = false,
    this.isCancelling = false,
  });

  TransactionDetailLoaded copyWith({
    TransactionModel? transaction,
    List<PlatformFile>? pendingFiles,
    bool? isUploading,
    bool? isCancelling,
  }) {
    return TransactionDetailLoaded(
      transaction: transaction ?? this.transaction,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      isUploading: isUploading ?? this.isUploading,
      isCancelling: isCancelling ?? this.isCancelling,
    );
  }

  @override
  List<Object?> get props =>
      [transaction, pendingFiles, isUploading, isCancelling];
}

class TransactionDetailError extends TransactionDetailState {
  final String message;

  const TransactionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
