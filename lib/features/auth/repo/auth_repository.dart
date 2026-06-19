import 'dart:io';

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/features/auth/models/signup_response.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:dio/dio.dart';

/// Handles authentication API and data access.
class AuthRepository {
  AuthRepository({
    required ApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  final ApiService _apiService;
  final CacheService _cacheService;

  /// Signup with citizen fields. Returns a [User] on success and saves the session.
  Future<User> signup({
    required String firstName,
    required String lastName,
    required String nationalNumber,
    required String phoneNumber,
    required String email,
    required String password,
    required String passwordConfirmation,
    required File identityImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'first_name': firstName,
        'last_name': lastName,
        'national_number': nationalNumber,
        'phone_number': phoneNumber,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'identity_image': await MultipartFile.fromFile(
          identityImage.path,
          filename: identityImage.path.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _apiService.post(
        EndPoints.signup,
        data: formData,
      );

      return _saveSessionFromResponse(response.data);
    } catch (error) {
      throw _mapToAuthException(error, fallback: 'فشل إنشاء الحساب');
    }
  }

  /// Login citizen via POST /api/v1/login (email + password).
  Future<User> loginCitizen(
    String email,
    String password, {
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.login,
        data: {
          'email': email,
          'password': password,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
        },
      );

      final user = await _saveSessionFromResponse(response.data);
      final role = _cacheService.getData(key: StorageKeys.role);

      if (role != null && role != 'Citizen') {
        await _clearSession();
        throw Exception('هذا التطبيق مخصص للمواطنين فقط');
      }

      return user;
    } catch (error) {
      throw _mapToAuthException(error, fallback: 'فشل تسجيل الدخول');
    }
  }

  /// Login with email and password. Returns a [User] on success and saves the session.
  Future<User> login(String email, String password) {
    return loginCitizen(email, password);
  }

  /// Invalidates the server session and clears local auth data.
  Future<void> logout() async {
    try {
      await _apiService.post(EndPoints.logout, data: const {});
    } catch (_) {
      // Still clear local session if the server is unreachable or token expired.
    } finally {
      await _clearSession();
    }
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _apiService.patch(
      EndPoints.fcmToken,
      data: {'fcm_token': fcmToken},
    );
  }

  Future<void> _clearSession() async {
    await _cacheService.removeData(key: StorageKeys.token);
    await _cacheService.removeData(key: StorageKeys.role);
  }

  Future<User> _saveSessionFromResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    final authResponse = SignupResponse.fromJson(data);

    if (!authResponse.success) {
      throw Exception(
        authResponse.message.isNotEmpty
            ? authResponse.message
            : 'فشلت العملية',
      );
    }

    await _cacheService.saveData(
      key: StorageKeys.token,
      value: authResponse.data.token,
    );

    final role = authResponse.data.role.isNotEmpty
        ? authResponse.data.role
        : authResponse.data.user.role;

    if (role != null && role.isNotEmpty) {
      await _cacheService.saveData(
        key: StorageKeys.role,
        value: role,
      );
    }

    return authResponse.data.user;
  }

  Exception _mapToAuthException(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      return Exception(_extractApiMessage(error) ?? fallback);
    }

    if (error is Exception) {
      return error;
    }

    return Exception(fallback);
  }

  String? _extractApiMessage(DioException exception) {
    final data = exception.response?.data;
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final message = data['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    final errors = data['errors'];
    if (errors is Map<String, dynamic> && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return firstError.first.toString();
      }
      if (firstError is String && firstError.isNotEmpty) {
        return firstError;
      }
    }

    return null;
  }
}
