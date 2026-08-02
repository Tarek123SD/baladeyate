import 'dart:async';
import 'dart:io';

import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';
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

  /// Returns the citizen's linked household, or `null` when none is registered (404).
  ///
  /// Throws when identity is not approved (403) or on other API failures.
  Future<RegisteredHousehold?> getMyHousehold() async {
    try {
      final response = await _apiService.get(EndPoints.myHousehold);

      // #region agent log
      unawaited(_agentDebugLog(
        hypothesisId: 'F',
        location: 'CitizenRepository.getMyHousehold',
        message: 'my_household_success',
        data: {
          'statusCode': response.statusCode,
          'hasData': response.data != null,
        },
      ));
      // #endregion

      return ApiResponseParser.parseItem(
        response.data,
        fromJson: RegisteredHousehold.fromJson,
        fallback: 'فشل استرجاع السجل السكني',
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;

      // #region agent log
      unawaited(_agentDebugLog(
        hypothesisId: 'F',
        location: 'CitizenRepository.getMyHousehold',
        message: 'my_household_error',
        data: {
          'statusCode': statusCode,
          'endpoint': EndPoints.myHousehold,
        },
      ));
      // #endregion

      if (statusCode == 404) {
        return null;
      }

      if (statusCode == 403) {
        final data = error.response?.data;
        final message = data is Map<String, dynamic>
            ? ApiResponseParser.extractMessage(data)
            : null;
        throw Exception(
          message ??
              'يجب توثيق حسابك وموافقة الإدارة أولاً لعرض السجل السكني.',
        );
      }

      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل استرجاع السجل السكني',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل استرجاع السجل السكني',
      );
    }
  }

  // #region agent log
  Future<void> _agentDebugLog({
    required String hypothesisId,
    required String location,
    required String message,
    Map<String, Object?> data = const {},
  }) async {
    try {
      await Dio().post(
        'http://127.0.0.1:7433/ingest/15820149-14bb-4635-9e4e-f55695fb17d8',
        data: {
          'sessionId': 'e5b8c1',
          'runId': 'flutter-wire',
          'hypothesisId': hypothesisId,
          'location': location,
          'message': message,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Debug-Session-Id': 'e5b8c1',
          },
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );
    } catch (_) {}
  }
  // #endregion
}
