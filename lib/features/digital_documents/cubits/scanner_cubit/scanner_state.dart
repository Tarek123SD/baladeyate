import 'package:equatable/equatable.dart';
import 'package:baladeyate/features/digital_documents/models/verified_document_model.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

/// Initial camera view state before scanning
class ScannerInitial extends ScannerState {
  const ScannerInitial();
}

/// Active camera scanning state
class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

/// Verification API call in progress
class ScannerLoading extends ScannerState {
  const ScannerLoading();
}

/// Document verification successful (valid document)
class ScannerSuccess extends ScannerState {
  final VerifiedDocumentModel document;

  const ScannerSuccess(this.document);

  @override
  List<Object?> get props => [document];
}

/// Document verification failed or invalid QR format (fake/invalid)
class ScannerError extends ScannerState {
  final String message;

  const ScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
