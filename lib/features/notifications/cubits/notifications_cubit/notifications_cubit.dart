import 'package:baladeyate/core/utils/api_response_parser.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/repo/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({required NotificationsRepository notificationsRepository})
      : _notificationsRepository = notificationsRepository,
        super(const NotificationsInitial());

  final NotificationsRepository _notificationsRepository;

  /// Number of unread notifications, safe to read from any state.
  int get unreadCount {
    final current = state;
    return current is NotificationsLoaded ? current.unreadCount : 0;
  }

  /// Fetch notifications from backend API
  Future<void> fetchNotifications() => loadNotifications();

  Future<void> loadNotifications() async {
    // Keep the current list visible while refreshing when we already have data.
    if (state is! NotificationsLoaded) {
      emit(const NotificationsLoading());
    }
    try {
      final notifications = await _notificationsRepository.getNotifications();
      emit(NotificationsLoaded(notifications: notifications));
    } catch (error) {
      final message = _messageFromError(error);
      if (state is NotificationsLoaded) {
        final current = state as NotificationsLoaded;
        emit(current.copyWith(actionError: message));
      } else {
        emit(NotificationsError(message));
      }
    }
  }

  /// Clears state on logout so a stale badge/list never leaks between sessions.
  void clear() => emit(const NotificationsInitial());

  /// Clears a transient inline error after it has been shown to the user.
  void clearActionError() {
    final current = state;
    if (current is NotificationsLoaded && current.actionError != null) {
      emit(current.copyWith(actionError: null));
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    final alreadyReadOrMissing = !current.notifications.any(
      (item) => item.id == notificationId && !item.isRead,
    );
    if (alreadyReadOrMissing) return;

    // Optimistically mark as read for instant feedback.
    final optimistic = current.notifications
        .map(
          (item) => item.id == notificationId
              ? item.copyWith(readAt: DateTime.now().toIso8601String())
              : item,
        )
        .toList();
    emit(NotificationsLoaded(notifications: optimistic));

    try {
      await _notificationsRepository.markAsRead(notificationId);
    } catch (error) {
      // Revert and surface the error without dropping the list.
      emit(
        current.copyWith(actionError: _messageFromError(error)),
      );
    }
  }

  Future<void> markAllAsRead() async {
    final current = state;
    if (current is! NotificationsLoaded || !current.hasUnread) return;

    final now = DateTime.now().toIso8601String();
    final optimistic = current.notifications
        .map((item) => item.isRead ? item : item.copyWith(readAt: now))
        .toList();
    emit(NotificationsLoaded(notifications: optimistic));

    try {
      await _notificationsRepository.markAllAsRead();
    } catch (error) {
      emit(
        current.copyWith(actionError: _messageFromError(error)),
      );
    }
  }

  String _messageFromError(Object error) {
    return ApiResponseParser.toUserMessage(
      error,
      fallback: 'تعذّر تحميل الإشعارات',
    );
  }
}
