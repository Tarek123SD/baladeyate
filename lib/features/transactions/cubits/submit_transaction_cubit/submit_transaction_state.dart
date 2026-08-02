import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

sealed class SubmitTransactionState extends Equatable {
  final String? selectedType;
  final List<PlatformFile> attachedFiles;
  final Map<String, dynamic> formData;

  const SubmitTransactionState({
    this.selectedType,
    this.attachedFiles = const [],
    this.formData = const {},
  });

  @override
  List<Object?> get props => [selectedType, attachedFiles, formData];
}

final class SubmitTransactionInitial extends SubmitTransactionState {
  const SubmitTransactionInitial({
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
  });
}

final class SubmitTransactionLoading extends SubmitTransactionState {
  const SubmitTransactionLoading({
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
  });
}

final class SubmitTransactionSuccess extends SubmitTransactionState {
  final String transactionNumber;

  const SubmitTransactionSuccess({
    required this.transactionNumber,
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
  });

  @override
  List<Object?> get props => [transactionNumber, selectedType, attachedFiles, formData];
}

final class SubmitTransactionFailure extends SubmitTransactionState {
  final String error;

  const SubmitTransactionFailure({
    required this.error,
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
  });

  @override
  List<Object?> get props => [error, selectedType, attachedFiles, formData];
}
