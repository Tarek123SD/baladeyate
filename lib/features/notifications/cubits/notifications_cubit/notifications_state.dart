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
  });

  final List<AppNotification> notifications;
  final bool isSubmitting;

  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    bool? isSubmitting,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [notifications, isSubmitting];
}

final class NotificationsFailure extends NotificationsState {
  const NotificationsFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
