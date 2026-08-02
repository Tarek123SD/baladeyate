import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_read_filters.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsEmptyState extends StatelessWidget {
  const NotificationsEmptyState({
    super.key,
    required this.readFilter,
    required this.onShowAll,
  });

  final NotificationsReadFilter readFilter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final isUnreadFilter = readFilter == NotificationsReadFilter.unread;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileEmptyState(
          icon: isUnreadFilter
              ? Icons.mark_email_read_rounded
              : Icons.notifications_off_outlined,
          title: isUnreadFilter
              ? 'لا توجد إشعارات غير مقروءة'
              : 'لا توجد إشعارات بعد',
          description: isUnreadFilter
              ? 'رائع! لقد اطلعت على جميع التنبيهات.'
              : 'ستظهر هنا أحدث التنبيهات والتحديثات الخاصة بك.',
        ),
        if (isUnreadFilter) ...[
          SizedBox(height: 12.h(context)),
          TextButton(
            onPressed: onShowAll,
            child: Text(
              'عرض الكل',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.w800,
                fontSize: 13.f(context),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
