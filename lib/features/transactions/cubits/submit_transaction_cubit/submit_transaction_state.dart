import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baladeyate/features/transactions/models/transaction_type_config.dart';

sealed class SubmitTransactionState extends Equatable {
  final String? selectedType;
  final List<PlatformFile> attachedFiles;
  final Map<String, dynamic> formData;
  final List<TransactionTypeConfig> types;
  final bool isLoadingTypes;

  const SubmitTransactionState({
    this.selectedType,
    this.attachedFiles = const [],
    this.formData = const {},
    this.types = const [],
    this.isLoadingTypes = false,
  });

  TransactionTypeConfig? get selectedTypeConfig {
    if (selectedType == null) return null;
    for (final type in types) {
      if (type.type == selectedType) return type;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        selectedType,
        attachedFiles,
        formData,
        types,
        isLoadingTypes,
      ];
}

final class SubmitTransactionInitial extends SubmitTransactionState {
  const SubmitTransactionInitial({
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
    super.types = const [],
    super.isLoadingTypes = false,
  });
}

final class SubmitTransactionLoading extends SubmitTransactionState {
  const SubmitTransactionLoading({
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
    super.types = const [],
    super.isLoadingTypes = false,
  });
}

final class SubmitTransactionSuccess extends SubmitTransactionState {
  final String transactionNumber;

  const SubmitTransactionSuccess({
    required this.transactionNumber,
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
    super.types = const [],
    super.isLoadingTypes = false,
  });

  @override
  List<Object?> get props => [
        transactionNumber,
        selectedType,
        attachedFiles,
        formData,
        types,
        isLoadingTypes,
      ];
}

final class SubmitTransactionFailure extends SubmitTransactionState {
  final String error;

  const SubmitTransactionFailure({
    required this.error,
    super.selectedType,
    super.attachedFiles = const [],
    super.formData = const {},
    super.types = const [],
    super.isLoadingTypes = false,
  });

  @override
  List<Object?> get props => [
        error,
        selectedType,
        attachedFiles,
        formData,
        types,
        isLoadingTypes,
      ];
}
