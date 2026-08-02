import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/features/digital_documents/repo/digital_documents_repository.dart';
import 'scanner_state.dart';

class ScannerCubit extends Cubit<ScannerState> {
  final DigitalDocumentsRepository _repository;

  ScannerCubit({required DigitalDocumentsRepository repository})
      : _repository = repository,
        super(const ScannerInitial());

  /// Processes the scanned raw QR code string and calls the verification endpoint.
  Future<void> verifyScannedCode(String rawCode) async {
    if (state is ScannerLoading) return;

    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) {
      emit(const ScannerError('لم يتم العثور على بيانات في رمز QR'));
      return;
    }

    String? transactionNumber;

    try {
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final Map<String, dynamic> json = jsonDecode(trimmed);
        transactionNumber = json['number']?.toString() ??
            json['transaction_number']?.toString() ??
            json['transactionNumber']?.toString() ??
            json['id']?.toString();
      } else {
        // Plain text transaction number fallback
        transactionNumber = trimmed;
      }
    } on FormatException {
      emit(const ScannerError('رمز QR غير صالح أو أن تـنسيق البيانات غير معروف'));
      return;
    } catch (_) {
      emit(const ScannerError('فشل قراءة رمز QR، يرجى المحاولة مرة أخرى'));
      return;
    }

    if (transactionNumber == null || transactionNumber.isEmpty) {
      emit(const ScannerError('رمز QR لا يحتوي على رقم معاملة صالح'));
      return;
    }

    emit(const ScannerLoading());

    try {
      final verifiedDoc = await _repository.verifyDocument(transactionNumber);
      emit(ScannerSuccess(verifiedDoc));
    } catch (error) {
      emit(ScannerError(error.toString()));
    }
  }

  /// Resumes the scanner state for a new scan.
  void resetScanner() {
    emit(const ScannerScanning());
  }
}
