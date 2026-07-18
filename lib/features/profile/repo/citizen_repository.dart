import 'dart:io';

import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:dio/dio.dart';

class CitizenRepository {
  CitizenRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  Future<User> updateProfile({String? phoneNumber}) async {
    try {
      final response = await _apiService.patch(
        EndPoints.profile,
        data: {
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final payload = ApiResponseParser.expectData(response.data);
      if (payload is! Map<String, dynamic>) {
        throw Exception('استجابة غير صالحة من الخادم');
      }

      return User.fromJson(payload);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تحديث الملف الشخصي');
    }
  }

  /// Submits the identity for verification.
  ///
  /// The API responds with only the new `verification_status` (no user
  /// profile), so we return that string and let callers merge it onto the
  /// existing user instead of replacing it.
  Future<String> verifyIdentity({
    required String nationalId,
    required File identityImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'national_id': nationalId,
        'identity_image': await MultipartFile.fromFile(
          identityImage.path,
          filename: identityImage.path.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _apiService.post(
        EndPoints.verifyIdentity,
        data: formData,
      );

      final payload = ApiResponseParser.expectData(response.data);
      if (payload is Map<String, dynamic> &&
          payload['verification_status'] is String) {
        return payload['verification_status'] as String;
      }

      return 'pending';
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل إرسال طلب التوثيق');
    }
  }



  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _apiService.post(
        EndPoints.fcmToken,
        data: {'fcm_token': fcmToken},
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحديث رمز الإشعارات',
      );
    }
  }
}
