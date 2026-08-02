import 'dart:io';

import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/donations/models/donation_case.dart';
import 'package:dio/dio.dart';

class DonationsRepository {
  DonationsRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<DonationCase>> getCases({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        EndPoints.donations,
        queryParams: {'page': page, 'limit': limit},
      );

      return ApiResponseParser.parseList(
        response.data,
        fromJson: DonationCase.fromJson,
        fallback: 'فشل تحميل الحملات',
      );
    } catch (error) {
      // The dashboard-managed endpoint may not be published yet; treat a
      // missing resource as "no campaigns" so the UI shows a clean state.
      if (error is DioException && error.response?.statusCode == 404) {
        return const <DonationCase>[];
      }
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الحملات');
    }
  }

  Future<DonationCase> getCaseById(int id) async {
    try {
      final response = await _apiService.get(EndPoints.donationById(id));

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: DonationCase.fromJson,
        fallback: 'فشل تحميل الحملة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحميل الحملة');
    }
  }

  Future<void> submitDonation({
    required int id,
    required num amount,
    required File receiptImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'amount': amount,
        'receipt_image': await MultipartFile.fromFile(
          receiptImage.path,
          filename: receiptImage.path.split(RegExp(r'[/\\]')).last,
        ),
      });

      await _apiService.post(
        EndPoints.donationDonate(id),
        data: formData,
      );
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إرسال التبرع');
    }
  }
}
