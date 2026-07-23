import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/digital_documents/models/digital_document_model.dart';

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
}
