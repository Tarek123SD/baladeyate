import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/core/utils/attachment_compressor.dart';
import 'package:baladeyate/features/transactions/models/transaction_model.dart';

class TransactionsRepository {
  final ApiService _apiService;

  TransactionsRepository({required ApiService apiService})
      : _apiService = apiService;

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
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل جلب قائمة المعاملات',
      );
    }
  }

  Future<TransactionModel> getTransactionById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.transactionById(id));
      return ApiResponseParser.parseItem<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل جلب تفاصيل المعاملة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل جلب تفاصيل المعاملة',
      );
    }
  }

  Future<String> submitTransaction({
    required String type,
    required Map<String, dynamic> formData,
    int? buildingId,
    required List<PlatformFile> attachments,
  }) async {
    try {
      final formPayload = FormData();
      formPayload.fields.add(MapEntry('type', type));
      if (buildingId != null) {
        formPayload.fields.add(MapEntry('building_id', buildingId.toString()));
      }
      formPayload.fields.add(MapEntry('form_data', jsonEncode(formData)));

      final multipartFiles = await _toMultipartFiles(attachments);
      for (var i = 0; i < multipartFiles.length; i++) {
        formPayload.files.add(MapEntry('attachments[$i]', multipartFiles[i]));
      }

      final response = await _apiService.post(
        EndPoints.transactions,
        data: formPayload,
      );

      final payload = ApiResponseParser.expectData(response.data);
      if (payload is Map<String, dynamic> &&
          payload['transaction_number'] != null) {
        return payload['transaction_number'].toString();
      }

      throw Exception('لم يتم إرجاع رقم المعاملة من الخادم');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تقديم المعاملة');
    }
  }

  Future<TransactionModel> uploadDocuments({
    required int transactionId,
    required List<PlatformFile> attachments,
  }) async {
    try {
      final multipartFiles = await _toMultipartFiles(attachments);
      if (multipartFiles.isEmpty) {
        throw Exception('يرجى إرفاق ملف واحد على الأقل');
      }

      final payload = FormData();
      for (var i = 0; i < multipartFiles.length; i++) {
        payload.files.add(MapEntry('attachments[$i]', multipartFiles[i]));
      }

      final response = await _apiService.post(
        EndPoints.transactionDocuments(transactionId),
        data: payload,
      );

      return ApiResponseParser.parseItem<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل رفع الوثائق',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل رفع الوثائق');
    }
  }

  Future<TransactionModel> cancelTransaction(int transactionId) async {
    try {
      final response = await _apiService.patch(
        EndPoints.transactionCancel(transactionId),
        data: <String, dynamic>{},
      );
      return ApiResponseParser.parseItem<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل إلغاء المعاملة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إلغاء المعاملة');
    }
  }

  Future<List<TransactionModel>> getDelegateTransactions() async {
    try {
      final response = await _apiService.get(EndPoints.delegateTransactions);
      return ApiResponseParser.parseList<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل جلب معاملات المعاينة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل جلب معاملات المعاينة',
      );
    }
  }

  Future<TransactionModel> getDelegateTransactionById(int id) async {
    try {
      final response =
          await _apiService.get(EndPoints.delegateTransactionById(id));
      return ApiResponseParser.parseItem<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل جلب تفاصيل المعاملة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل جلب تفاصيل المعاملة',
      );
    }
  }

  Future<TransactionModel> submitInspection({
    required int transactionId,
    required String inspectionNotes,
  }) async {
    try {
      final response = await _apiService.patch(
        EndPoints.delegateTransactionInspect(transactionId),
        data: {'inspection_notes': inspectionNotes},
      );
      return ApiResponseParser.parseItem<TransactionModel>(
        response.data,
        fromJson: TransactionModel.fromJson,
        fallback: 'فشل تقديم تقرير المعاينة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تقديم تقرير المعاينة',
      );
    }
  }

  Future<List<MultipartFile>> _toMultipartFiles(
    List<PlatformFile> attachments,
  ) async {
    final prepared = await AttachmentCompressor.prepare(attachments);
    final multipartFiles = <MultipartFile>[];
    for (final file in prepared) {
      if (file.size > 5 * 1024 * 1024) {
        throw Exception('حجم الملف ${file.name} يتجاوز 5 ميغابايت');
      }
      if (file.path != null) {
        multipartFiles.add(
          await MultipartFile.fromFile(file.path!, filename: file.name),
        );
      } else if (file.bytes != null) {
        multipartFiles.add(
          MultipartFile.fromBytes(file.bytes!, filename: file.name),
        );
      }
    }
    return multipartFiles;
  }
}
