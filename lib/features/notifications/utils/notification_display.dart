import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';

String formatNotificationTime(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return 'الآن';
  }

  final parsed = DateTime.tryParse(createdAt);
  if (parsed == null) {
    return createdAt;
  }

  final diff = DateTime.now().difference(parsed);
  if (diff.inMinutes < 60) {
    return 'منذ ${diff.inMinutes} دقيقة';
  }
  if (diff.inHours < 24) {
    return 'منذ ${diff.inHours} ساعة';
  }
  if (diff.inDays < 7) {
    return 'منذ ${diff.inDays} يوم';
  }

  return '${parsed.day}/${parsed.month}/${parsed.year}';
}

IconData iconForNotificationType(String type) {
  switch (type) {
    case 'ComplaintStatusUpdatedNotification':
      return Icons.receipt_long_outlined;
    case 'NewTaskAssignedNotification':
      return Icons.assignment_outlined;
    case 'CitizenGeneralNotification':
      return Icons.notifications_none_outlined;
    case 'IdentityVerificationNotification':
      return Icons.verified_user_outlined;
    case 'BulkNotification':
      return Icons.campaign_outlined;
    default:
      return Icons.info_outline;
  }
}

Color iconColorForNotificationType(String type) {
  switch (type) {
    case 'ComplaintStatusUpdatedNotification':
      return AppColors.primaryGoldenWheat;
    case 'NewTaskAssignedNotification':
      return AppColors.green;
    case 'CitizenGeneralNotification':
      return AppColors.primaryForest;
    case 'IdentityVerificationNotification':
      return AppColors.green;
    case 'BulkNotification':
      return AppColors.primaryForest;
    default:
      return AppColors.secondaryCharcoal;
  }
}

String notificationDescription(AppNotification notification) {
  final message = notification.message.trim();
  if (message.isNotEmpty) {
    return message;
  }
  return 'لا توجد تفاصيل إضافية.';
}
