import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_type_chip.dart';
import 'package:baladeyate/features/notifications/presentation/notification_display.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsCategoryFilters extends StatelessWidget {
  const NotificationsCategoryFilters({
    super.key,
    required this.notifications,
    required this.selected,
    required this.onChanged,
  });

  final List<AppNotification> notifications;
  final NotificationCategory? selected;
  final ValueChanged<NotificationCategory?> onChanged;

  @override
  Widget build(BuildContext context) {
    final counts = <NotificationCategory, int>{};
    for (final item in notifications) {
      final category = categoryForNotificationType(item.type);
      counts[category] = (counts[category] ?? 0) + 1;
    }

    final available = NotificationCategory.values
        .where((category) => (counts[category] ?? 0) > 0)
        .toList();

    if (available.length <= 1) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          NotificationsTypeChip(
            label: 'كل الأنواع',
            selected: selected == null,
            onTap: () => onChanged(null),
          ),
          SizedBox(width: 8.w(context)),
          for (final category in available) ...[
            NotificationsTypeChip(
              label:
                  '${labelForNotificationCategory(category)} ${counts[category]}',
              selected: selected == category,
              onTap: () => onChanged(category),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }
}
