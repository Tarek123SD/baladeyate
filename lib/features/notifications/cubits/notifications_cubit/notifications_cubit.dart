import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/repo/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required NotificationsRepository notificationsRepository})
      : _notificationsRepository = notificationsRepository,
        super(const NotificationsInitial());

  final NotificationsRepository _notificationsRepository;

  Future<void> loadNotifications() async {
    emit(const NotificationsLoading());
    try {
      final notifications = await _notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (error) {
      emit(NotificationsFailure(message: _messageFromError(error)));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    emit(current.copyWith(isSubmitting: true));
    try {
      await _notificationsRepository.markAsRead(notificationId);
      final notifications = current.notifications
          .map(
            (item) => item.id == notificationId
                ? AppNotification(
                    id: item.id,
                    type: item.type,
                    data: item.data,
                    readAt: DateTime.now().toIso8601String(),
                    createdAt: item.createdAt,
                  )
                : item,
          )
          .toList();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (error) {
      emit(NotificationsFailure(message: _messageFromError(error)));
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    emit(current.copyWith(isSubmitting: true));
    try {
      await _notificationsRepository.markAllAsRead();
      final now = DateTime.now().toIso8601String();
      final notifications = current.notifications
          .map(
            (item) => AppNotification(
              id: item.id,
              type: item.type,
              data: item.data,
              readAt: now,
              createdAt: item.createdAt,
            ),
          )
          .toList();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (error) {
      emit(NotificationsFailure(message: _messageFromError(error)));
    }
  }

  String _messageFromError(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '');
    return message.isNotEmpty ? message : 'حدث خطأ غير متوقع';
  }
}
