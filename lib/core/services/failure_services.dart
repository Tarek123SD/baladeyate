import 'package:baladeyate/core/services/failure_service/auth_failure.dart';
import 'package:baladeyate/core/services/failure_service/failure.dart';
import 'package:baladeyate/core/services/failure_service/generice_failure.dart';
import 'package:baladeyate/core/services/failure_service/internet_failure.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class FailureFactory extends Failure {
  FailureFactory(super.message);
  static Failure fromDioException(DioException e) {
    final message = ApiResponseParser.toUserMessage(
      e,
      fallback: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
    );

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return InternetFailure(message);
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return AuthFailure(message);
        }
        return GenericFailureFactory(message);
      default:
        return GenericFailureFactory(message);
    }
  }

  @override
  Future<void> handle(BuildContext context, {void Function()? onRetry}) {
    return GenericFailureFactory(message).handle(context, onRetry: onRetry);
  }
}
