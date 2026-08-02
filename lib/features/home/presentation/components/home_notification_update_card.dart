import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/notification_display.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeNotificationUpdateCard extends StatelessWidget {
  const HomeNotificationUpdateCard({
    super.key,
    required this.notification,
    required this.onActionTap,
  });

  final AppNotification notification;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final typeLower = notification.type.toLowerCase();
    IconData icon;
    Color iconColor;
    Color bgColor;

    if (typeLower.contains('transaction')) {
      icon = AppIcons.statsDone;
      iconColor = const Color(0xFF2E7D32);
      bgColor = const Color(0xFFE8F5E9);
    } else if (typeLower.contains('complaint')) {
      icon = AppIcons.complaint;
      iconColor = const Color(0xFF1565C0);
      bgColor = const Color(0xFFE3F2FD);
    } else {
      icon = AppIcons.announcements;
      iconColor = const Color(0xFFC62828);
      bgColor = const Color(0xFFFFEBEE);
    }

    final String ctaText = typeLower.contains('transaction')
        ? 'عرض المعاملة'
        : typeLower.contains('complaint')
            ? 'عرض الشكوى'
            : 'عرض التفاصيل';

    final formattedTime = formatNotificationTime(notification.createdAt);
    final subtitle = notificationDescription(notification);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h(context)),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r(context)),
          side: BorderSide(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 0.8.w(context),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.s(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.s(context),
                    height: 48.s(context),
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24.ic(context),
                    ),
                  ),
                  SizedBox(width: 16.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14.f(context),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF212121),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        SizedBox(height: 6.h(context)),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.f(context),
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w(context)),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 11.f(context),
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h(context)),
              Divider(
                height: 1.h(context),
                thickness: 0.6,
                color: Colors.grey[200],
              ),
              SizedBox(height: 8.h(context)),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onActionTap,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.s(context),
                      vertical: 4.s(context),
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(
                    Icons.chevron_left,
                    size: 18.ic(context),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  label: Text(
                    ctaText,
                    style: TextStyle(
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
