import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

enum NotificationsReadFilter { all, unread }

class NotificationsReadFilters extends StatelessWidget {
  const NotificationsReadFilters({
    super.key,
    required this.state,
    required this.selected,
    required this.onChanged,
  });

  final NotificationsLoaded state;
  final NotificationsReadFilter selected;
  final ValueChanged<NotificationsReadFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        NotificationsFilterChip(
          label: 'الكل',
          count: state.notifications.length,
          isSelected: selected == NotificationsReadFilter.all,
          onTap: () => onChanged(NotificationsReadFilter.all),
        ),
        SizedBox(width: 8.w(context)),
        NotificationsFilterChip(
          label: 'غير مقروء',
          count: state.unreadCount,
          isSelected: selected == NotificationsReadFilter.unread,
          highlight: state.unreadCount > 0,
          onTap: () => onChanged(NotificationsReadFilter.unread),
        ),
      ],
    );
  }
}
