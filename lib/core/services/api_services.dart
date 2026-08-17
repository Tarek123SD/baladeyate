import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const Duration _multipartTimeout = Duration(minutes: 2);

  final Dio _dio;

  ApiService({required Dio dio}) : _dio = dio;

  // ----------GET Request----------
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Object? data,
    Options? options,
  }) async {
    printUrl(endpoint);

    final response = await _dio.get(
      endpoint,
      queryParameters: queryParams,
      data: data,
      options: options,
    );
    printResponse(response);
    return response;
  }

  // ----------POST Request----------
  Future<Response> post(
    String endpoint, {
    required Object? data,
    Options? options,
  }) async {
    printUrl(endpoint);
    final response = await _dio.post(
      endpoint,
      data: data,
      options: _optionsFor(data, options),
    );
    printResponse(response);
    return response;
  }

  // ----------Delete Request----------
  Future<Response> delete(String endpoint, {required Object? data}) async {
    printUrl(endpoint);
    final response = await _dio.delete(endpoint, data: data);
    printResponse(response);
    return response;
  }

  // ----------PUT Request----------
  Future<Response> put(String endpoint, {required Object? data}) async {
    printUrl(endpoint);
    final response = await _dio.put(endpoint, data: data);
    printResponse(response);
    return response;
  }

  // ----------PATCH Request----------
  Future<Response> patch(
    String endpoint, {
    required Object? data,
    Options? options,
  }) async {
    printUrl(endpoint);
    final response = await _dio.patch(endpoint, data: data, options: options);
    printResponse(response);
    return response;
  }

  /// Lets Dio set `multipart/form-data; boundary=...` itself.
  Options? _optionsFor(Object? data, Options? options) {
    if (data is! FormData) {
      return options;
    }

    final headers = Map<String, dynamic>.from(options?.headers ?? const {});
    headers.remove(Headers.contentTypeHeader);
    headers.remove('Content-Type');
    headers.remove('content-type');

    return Options(
      method: options?.method,
      sendTimeout: options?.sendTimeout ?? _multipartTimeout,
      receiveTimeout: options?.receiveTimeout ?? _multipartTimeout,
      extra: options?.extra,
      headers: headers,
      responseType: options?.responseType,
      contentType: null,
      validateStatus: options?.validateStatus,
      receiveDataWhenStatusError: options?.receiveDataWhenStatusError,
      followRedirects: options?.followRedirects,
      maxRedirects: options?.maxRedirects,
      persistentConnection: options?.persistentConnection,
      requestEncoder: options?.requestEncoder,
      responseDecoder: options?.responseDecoder,
      listFormat: options?.listFormat,
    );
  }

  void printUrl(String endpoint) {
    debugPrint('${_dio.options.baseUrl}$endpoint');
  }

  void printResponse(Response<dynamic> response) {
    debugPrint('response =>${response.statusCode}\n${response.data}');
  }
}
