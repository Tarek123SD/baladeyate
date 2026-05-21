// lib/core/services/auth_interceptor.dart

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:dio/dio.dart';

import '../cache_service.dart';

class AuthInterceptor extends Interceptor {
  final CacheService _cacheService;

  AuthInterceptor({required CacheService cacheService})
    : _cacheService = cacheService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String? token = _cacheService.getData(key: StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}
