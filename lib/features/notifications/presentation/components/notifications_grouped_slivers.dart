import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/components/notification_list_item.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_section_header.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

enum NotificationTimeGroup { today, yesterday, earlier }

class NotificationsGroupedSlivers {
  const NotificationsGroupedSlivers._();

  static List<Widget> build({
    required BuildContext context,
    required List<AppNotification> notifications,
    required double horizontalPadding,
    required ValueChanged<AppNotification> onTap,
    required Future<void> Function(AppNotification notification) onMarkAsRead,
  }) {
    final groups = <NotificationTimeGroup, List<AppNotification>>{};
    for (final notification in notifications) {
      final group = groupFor(notification.createdAt);
      groups.putIfAbsent(group, () => []).add(notification);
    }

    final orderedGroups = [
      NotificationTimeGroup.today,
      NotificationTimeGroup.yesterday,
      NotificationTimeGroup.earlier,
    ].where((g) => groups.containsKey(g));

    var animationIndex = 0;
    final slivers = <Widget>[];

    for (final group in orderedGroups) {
      final items = groups[group]!;
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            6.h(context),
            horizontalPadding,
            4.h(context),
          ),
          sliver: SliverToBoxAdapter(
            child: ProfileSectionHeader(
              title: labelFor(group),
              badge: '${items.length}',
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h(context)),
            itemBuilder: (context, index) {
              final notification = items[index];
              final currentIndex = animationIndex++;

              return NotificationListItem(
                notification: notification,
                animationIndex: currentIndex,
                onTap: () => onTap(notification),
                onMarkAsRead: () => onMarkAsRead(notification),
              );
            },
          ),
        ),
      );
    }

    return slivers;
  }

  static NotificationTimeGroup groupFor(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return NotificationTimeGroup.today;
    }

    final parsed = DateTime.tryParse(createdAt)?.toLocal();
    if (parsed == null) {
      return NotificationTimeGroup.earlier;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return NotificationTimeGroup.today;
    if (diff == 1) return NotificationTimeGroup.yesterday;
    return NotificationTimeGroup.earlier;
  }

  static String labelFor(NotificationTimeGroup group) {
    switch (group) {
      case NotificationTimeGroup.today:
        return 'اليوم';
      case NotificationTimeGroup.yesterday:
        return 'أمس';
      case NotificationTimeGroup.earlier:
        return 'سابقاً';
    }
  }
}
