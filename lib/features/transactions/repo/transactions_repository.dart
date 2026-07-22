import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';

import 'package:baladeyate/features/transactions/models/transaction_model.dart';

class TransactionsRepository {
  final ApiService _apiService;

  TransactionsRepository({required ApiService apiService}) : _apiService = apiService;

  /// Fetches citizen transactions from GET /api/v1/transactions with optional type/status filters.
  Future<List<TransactionModel>> getTransactions({
    String? type,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        EndPoints.transactions,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      return ApiResponseParser.parseList<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل جلب قائمة المعاملات',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل جلب قائمة المعاملات');
    }
  }

  /// Submits a municipal transaction with attachments.
  Future<String> submitTransaction({
    required String type,
    required Map<String, dynamic> formData,
    int? buildingId,
    required List<PlatformFile> attachments,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'type': type,
      };

      if (buildingId != null) {
        requestData['building_id'] = buildingId;
      }

      // Add formData fields as form_data[key]
      formData.forEach((key, value) {
        requestData['form_data[$key]'] = value;
      });

      // Add attachments as MultipartFile
      final List<MultipartFile> multipartFiles = [];
      for (final file in attachments) {
        if (file.path != null) {
          multipartFiles.add(
            await MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            ),
          );
        } else if (file.bytes != null) {
          multipartFiles.add(
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            ),
          );
        }
      }

      if (multipartFiles.isNotEmpty) {
        requestData['attachments[]'] = multipartFiles;
      }

      final formDataObject = FormData.fromMap(requestData);

      final response = await _apiService.post(
        EndPoints.transactions,
        data: formDataObject,
      );

      final payload = ApiResponseParser.expectData(response.data);
      if (payload is Map<String, dynamic> && payload['transaction_number'] != null) {
        return payload['transaction_number'].toString();
      }

      throw Exception('لم يتم إرجاع رقم المعاملة من الخادم');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تقديم المعاملة');
    }
  }
}
