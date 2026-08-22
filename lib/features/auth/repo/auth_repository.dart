import 'dart:convert';
import 'dart:io';

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/auth/models/login_challenge.dart';
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
      throw ApiResponseParser.mapError(error, fallback: 'فشل إنشاء الحساب');
    }
  }

  /// Password step of mobile login. Returns a challenge; no Sanctum token yet.
  Future<LoginChallenge> login(
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

      return _readLoginChallenge(response.data, fallbackEmail: email);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل تسجيل الدخول');
    }
  }

  /// Completes login 2FA and persists the normal session.
  Future<User> verifyLoginOtp({
    required String email,
    required String otp,
    required String challengeToken,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.verifyLoginOtp,
        data: {
          'email': email,
          'otp': otp,
          'challenge_token': challengeToken,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
        },
      );

      return _saveSessionFromResponse(response.data);
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل التحقق من الرمز');
    }
  }

  /// Resends the login OTP for an existing challenge (same pattern as reset).
  Future<String> resendLoginOtp({
    required String email,
    required String challengeToken,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.resendLoginOtp,
        data: {
          'email': email,
          'challenge_token': challengeToken,
        },
      );
      return _readSuccessMessage(
        response.data,
        fallback: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل إرسال رمز التحقق',
      );
    }
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
    await _apiService.post(
      EndPoints.fcmToken,
      data: {'fcm_token': fcmToken},
    );
  }

  /// Sends a 6-digit OTP to the user's email.
  Future<String> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post(
        EndPoints.forgotPassword,
        data: {'email': email},
      );
      return _readSuccessMessage(
        response.data,
        fallback: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل إرسال رمز التحقق',
      );
    }
  }

  /// Verifies the 6-digit OTP and returns the `reset_token` for the final step.
  Future<String> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final success = data['success'];
        if (success == false) {
          final message = data['message'];
          throw Exception(
            message is String && message.isNotEmpty
                ? message
                : 'رمز التحقق غير صحيح',
          );
        }
        final token = data['data']?['reset_token'];
        if (token is String && token.isNotEmpty) return token;
      }
      throw Exception('لم يتم استلام رمز إعادة التعيين');
    } catch (error) {
      throw ApiResponseParser.mapError(error, fallback: 'فشل التحقق من الرمز');
    }
  }

  /// Resets the password using the `reset_token` obtained from [verifyOtp].
  Future<String> resetPassword({
    required String email,
    required String password,
    required String passwordConfirmation,
    /// Token returned by the verify-otp step (new 3-step flow).
    String? resetToken,
    /// Raw OTP (legacy single-step flow – kept for backward compatibility).
    String? otp,
  }) async {
    try {
      final response = await _apiService.post(
        EndPoints.resetPassword,
        data: {
          'email': email,
          if (resetToken != null && resetToken.isNotEmpty)
            'reset_token': resetToken,
          if (otp != null && otp.isNotEmpty) 'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return _readSuccessMessage(
        response.data,
        fallback: 'تم تغيير كلمة المرور بنجاح',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تغيير كلمة المرور',
      );
    }
  }

  String? get storedToken => _cacheService.getData(key: StorageKeys.token);

  bool get hasStoredSession {
    final token = storedToken;
    return token != null && token.isNotEmpty;
  }

  /// Cached user from the last persisted session, if any.
  User? get cachedUser => _readCachedUser();

  /// Restores the session from SharedPreferences and refreshes the profile when possible.
  Future<User?> restoreSession() async {
    if (!hasStoredSession) return null;

    final cachedUser = _readCachedUser();

    // The backend exposes no GET route for the current user, so we can only
    // refresh through the PATCH profile endpoint, which needs the phone number.
    final phoneNumber = cachedUser?.phoneNumber;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return cachedUser;
    }

    try {
      final user = await refreshCurrentUser(phoneNumber: phoneNumber);
      await persistUser(user);
      if (user.role != null && user.role!.isNotEmpty) {
        await _cacheService.saveData(
          key: StorageKeys.role,
          value: user.role!,
        );
      }
      return user;
    } catch (error) {
      if (error is DioException &&
          (error.response?.statusCode == 401 ||
              error.response?.statusCode == 403)) {
        await _clearSession();
        return null;
      }
      return cachedUser;
    }
  }

  /// Fetches the latest user by issuing a no-op profile update.
  ///
  /// The API has no GET endpoint for the current user; `PATCH /v1/profile`
  /// returns the full user (including verification status) and only accepts
  /// form-encoded bodies, so we resend the current phone number unchanged.
  Future<User> refreshCurrentUser({required String phoneNumber}) async {
    final response = await _apiService.patch(
      EndPoints.profile,
      data: {'phone_number': phoneNumber},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final payload = ApiResponseParser.expectData(response.data);

    if (payload is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    return User.fromJson(payload);
  }

  Future<void> persistUser(User user) async {
    await _cacheService.saveData(
      key: StorageKeys.user,
      value: jsonEncode(user.toJson()),
    );
  }

  User? _readCachedUser() {
    final raw = _cacheService.getData(key: StorageKeys.user);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return User.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearSession() async {
    await _cacheService.removeData(key: StorageKeys.token);
    await _cacheService.removeData(key: StorageKeys.role);
    await _cacheService.removeData(key: StorageKeys.user);
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

    await persistUser(authResponse.data.user);

    return authResponse.data.user;
  }

  LoginChallenge _readLoginChallenge(dynamic data, {required String fallbackEmail}) {
    if (data is! Map<String, dynamic>) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    if (data['success'] == false) {
      throw Exception(
        ApiResponseParser.toUserMessage(
          Exception(ApiResponseParser.extractMessage(data) ?? 'فشل تسجيل الدخول'),
          fallback: 'فشل تسجيل الدخول',
        ),
      );
    }

    final payload = data['data'];
    if (payload is! Map) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    final requiresOtp = payload['requires_otp'] == true;
    final challengeToken = payload['challenge_token'];
    if (!requiresOtp || challengeToken is! String || challengeToken.isEmpty) {
      throw Exception('استجابة غير صالحة من الخادم');
    }

    final email = payload['email'];
    final expiresIn = payload['expires_in'];
    final message = data['message'];

    return LoginChallenge(
      email: email is String && email.isNotEmpty ? email : fallbackEmail,
      challengeToken: challengeToken,
      message: message is String && message.isNotEmpty
          ? message
          : 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      expiresIn: expiresIn is int ? expiresIn : 900,
    );
  }

  String _readSuccessMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final success = data['success'];
      if (success == false) {
        throw Exception(
          ApiResponseParser.toUserMessage(
            Exception(ApiResponseParser.extractMessage(data) ?? fallback),
            fallback: fallback,
          ),
        );
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}
