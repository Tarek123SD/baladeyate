import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsUnreadBanner extends StatelessWidget {
  const NotificationsUnreadBanner({
    super.key,
    required this.unreadCount,
    required this.onMarkAllRead,
    this.isSubmitting = false,
  });

  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w(context),
        vertical: 10.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.mark_email_unread_rounded,
            color: AppColors.primaryForest,
            size: 18.ic(context),
          ),
          SizedBox(width: 8.w(context)),
          Expanded(
            child: Text(
              unreadCount == 1
                  ? 'لديك إشعار واحد غير مقروء'
                  : 'لديك $unreadCount إشعارات غير مقروءة',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: isSubmitting ? null : onMarkAllRead,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryForest,
              padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 14.s(context),
                    height: 14.s(context),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'تم الكل',
                    style: TextStyle(
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
