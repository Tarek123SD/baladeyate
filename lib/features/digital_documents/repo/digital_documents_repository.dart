import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/digital_documents/models/digital_document_model.dart';

import 'package:baladeyate/features/digital_documents/models/verified_document_model.dart';

class DigitalDocumentsRepository {
  final ApiService _apiService;

  DigitalDocumentsRepository({required ApiService apiService})
      : _apiService = apiService;

  /// Fetches citizen approved digital documents from GET /api/v1/citizen/digital-documents
  Future<List<DigitalDocumentModel>> getDigitalDocuments() async {
    try {
      final response = await _apiService.get(EndPoints.digitalDocuments);

      return ApiResponseParser.parseList<DigitalDocumentModel>(
        response.data,
        fromJson: DigitalDocumentModel.fromJson,
        fallback: 'فشل جلب الوثائق الرقمية',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل جلب الوثائق الرقمية',
      );
    }
  }

  /// Verifies a citizen digital document via POST /api/v1/delegate/verify-document
  Future<VerifiedDocumentModel> verifyDocument(String transactionNumber) async {
    try {
      final response = await _apiService.post(
        EndPoints.verifyDocument,
        data: {'transaction_number': transactionNumber},
      );

      return ApiResponseParser.parseItem<VerifiedDocumentModel>(
        response.data,
        fromJson: VerifiedDocumentModel.fromJson,
        fallback: 'فشل التحقق من الوثيقة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'وثيقة غير صالحة أو غير مسجلة في النظام',
      );
    }
  }
}

