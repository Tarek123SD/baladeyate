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

  static List<T> parseList<T>(
    dynamic data, {
    required T Function(Map<String, dynamic> json) fromJson,
    String? fallback,
  }) {
    final map = expectMap(data, fallback: fallback);
    final payload = map['data'];
    final List<dynamic> rawList;

    if (payload is List) {
      rawList = payload;
    } else if (payload is Map<String, dynamic> && payload['data'] is List) {
      rawList = payload['data'] as List<dynamic>;
    } else {
      rawList = const [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(fromJson)
        .toList();
  }

  static T parseItem<T>(
    dynamic data, {
    required T Function(Map<String, dynamic> json) fromJson,
    String? fallback,
  }) {
    final payload = expectData(data, fallback: fallback);
    if (payload is! Map<String, dynamic>) {
      throw Exception(fallback ?? 'استجابة غير صالحة من الخادم');
    }

    return fromJson(payload);
  }

  static Exception mapError(
    Object error, {
    required String fallback,
  }) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return Exception(
          'انتهت صلاحية الجلسة أو لا تملك صلاحية للوصول. يرجى تسجيل الدخول مجدداً.',
        );
      }
      if (statusCode == 413) {
        return Exception('حجم الملف كبير جدًا، يرجى اختيار صورة أصغر');
      }

      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final extractedMsg = extractMessage(data);
        if (extractedMsg != null && extractedMsg.isNotEmpty) {
          return Exception(extractedMsg);
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('انتهت مهلة الاتصال، تحقق من الإنترنت وحاول مرة أخرى');
        case DioExceptionType.connectionError:
          return Exception('تعذر الاتصال بالخادم، تحقق من الإنترنت');
        default:
          break;
      }

      return Exception(fallback);
    }

    if (error is Exception) {
      return error;
    }

    return Exception(fallback);
  }
}
