import 'package:dio/dio.dart';

class ApiResponseParser {
  ApiResponseParser._();

  static Map<String, dynamic> expectMap(dynamic data, {String? fallback}) {
    if (data is! Map<String, dynamic>) {
      throw Exception(fallback ?? 'استجابة غير صالحة من الخادم');
    }

    if (data['success'] == false) {
      throw Exception(extractMessage(data) ?? fallback ?? 'فشلت العملية');
    }

    return data;
  }

  static dynamic expectData(dynamic data, {String? fallback}) {
    return expectMap(data, fallback: fallback)['data'];
  }

  static String? extractMessage(Map<String, dynamic> data) {
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

  static Exception mapError(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return Exception(extractMessage(data) ?? fallback);
      }
      return Exception(fallback);
    }

    if (error is Exception) {
      return error;
    }

    return Exception(fallback);
  }
}
