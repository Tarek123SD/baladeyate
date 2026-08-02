import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/notification_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.animationIndex,
    required this.onTap,
    required this.onMarkAsRead,
  });

  final AppNotification notification;
  final int animationIndex;
  final VoidCallback onTap;
  final Future<void> Function() onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final typeLabel = shouldShowTypeLabel(
      title: notification.title,
      type: notification.type,
    )
        ? typeLabelForNotificationType(notification.type)
        : null;

    final card = CustomNotificationCard(
      isRead: notification.isRead,
      time: formatNotificationTime(notification.createdAt),
      title: notification.title,
      message: notificationDescription(notification),
      typeLabel: typeLabel,
      icon: iconForNotificationType(notification.type),
      iconColor: iconColorForNotificationType(notification.type),
      onTap: onTap,
    );

    return Dismissible(
      key: ValueKey('notification-${notification.id}'),
      direction: notification.isRead
          ? DismissDirection.none
          : DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await onMarkAsRead();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
        decoration: BoxDecoration(
          color: AppColors.primaryForest.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.done_rounded,
              color: AppColors.primaryForest,
              size: 18.ic(context),
            ),
            SizedBox(width: 6.w(context)),
            Text(
              'تم كمقروء',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      child: card
          .animate()
          .fadeIn(
            duration: 260.ms,
            delay: (30 * animationIndex).ms,
          )
          .slideY(begin: 0.04, end: 0),
    );
  }
}
