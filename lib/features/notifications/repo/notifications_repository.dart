import 'package:baladeyate/core/services/api_services.dart';
import 'package:baladeyate/core/services/end_points.dart';
import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';

class NotificationsRepository {
  NotificationsRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _apiService.get(EndPoints.notifications);
      return ApiResponseParser.parseList(
        response.data,
        fromJson: AppNotification.fromJson,
        fallback: 'فشل تحميل الإشعارات',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحميل الإشعارات',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.patch(
        EndPoints.notificationRead(notificationId),
        data: const {},
      );
      ApiResponseParser.expectMap(
        response.data,
        fallback: 'فشل تحديث الإشعار',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحديث الإشعار',
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.post(
        EndPoints.notificationsReadAll,
        data: const {},
      );
      ApiResponseParser.expectMap(
        response.data,
        fallback: 'فشل تحديد الإشعارات كمقروءة',
      );
    } catch (error) {
      throw ApiResponseParser.mapError(
        error,
        fallback: 'فشل تحديد الإشعارات كمقروءة',
      );
    }
  }
}
