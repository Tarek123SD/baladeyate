import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:equatable/equatable.dart';

sealed class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

final class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

final class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

final class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.notifications,
    this.isSubmitting = false,
    this.actionError,
  });

  final List<AppNotification> notifications;
  final bool isSubmitting;

  /// A transient error surfaced from an inline action (e.g. mark as read)
  /// while keeping the already loaded list on screen.
  final String? actionError;

  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;

  bool get hasUnread => unreadCount > 0;

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    bool? isSubmitting,
    String? actionError,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      actionError: actionError,
    );
  }

  @override
  List<Object?> get props => [notifications, isSubmitting, actionError];
}

final class NotificationsFailure extends NotificationsState {
  const NotificationsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
