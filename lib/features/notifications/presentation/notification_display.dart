import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';

/// High-level buckets used by notification type filters.
enum NotificationCategory {
  tasks,
  complaints,
  transactions,
  general,
}

String formatNotificationTime(String? createdAt) {
  if (createdAt == null || createdAt.isEmpty) {
    return 'الآن';
  }

  final parsed = DateTime.tryParse(createdAt)?.toLocal();
  if (parsed == null) {
    return createdAt;
  }

  final now = DateTime.now();
  final diff = now.difference(parsed);

  if (diff.isNegative || diff.inSeconds < 60) {
    return 'الآن';
  }
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return m == 1 ? 'منذ دقيقة' : 'منذ $m دقيقة';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    if (h == 1) return 'منذ ساعة';
    if (h == 2) return 'منذ ساعتين';
    if (h >= 3 && h <= 10) return 'منذ $h ساعات';
    return 'منذ $h ساعة';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    if (d == 1) return 'أمس';
    if (d == 2) return 'منذ يومين';
    if (d >= 3 && d <= 10) return 'منذ $d أيام';
    return 'منذ $d يوم';
  }

  final day = parsed.day.toString().padLeft(2, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  return '$day/$month/${parsed.year}';
}

IconData iconForNotificationType(String type) {
  switch (type) {
    case 'ComplaintStatusUpdatedNotification':
      return AppIcons.notifComplaint;
    case 'NewTaskAssignedNotification':
      return AppIcons.notifTask;
    case 'CitizenGeneralNotification':
      return AppIcons.notifGeneral;
    case 'IdentityVerificationNotification':
      return AppIcons.notifIdentity;
    case 'TransactionStatusUpdatedNotification':
      return AppIcons.notifTransaction;
    case 'BulkNotification':
      return AppIcons.notifBulk;
    default:
      return AppIcons.notifInfo;
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
    case 'TransactionStatusUpdatedNotification':
      return AppColors.thirdForest;
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

String typeLabelForNotificationType(String type) {
  switch (type) {
    case 'ComplaintStatusUpdatedNotification':
      return 'تحديث شكوى';
    case 'NewTaskAssignedNotification':
      return 'مهمة ميدانية';
    case 'CitizenGeneralNotification':
      return 'إشعار عام';
    case 'IdentityVerificationNotification':
      return 'توثيق الحساب';
    case 'TransactionStatusUpdatedNotification':
      return 'معاملة';
    case 'BulkNotification':
      return 'إشعار جماعي';
    default:
      return 'تنبيه';
  }
}

NotificationCategory categoryForNotificationType(String type) {
  switch (type) {
    case 'NewTaskAssignedNotification':
      return NotificationCategory.tasks;
    case 'ComplaintStatusUpdatedNotification':
      return NotificationCategory.complaints;
    case 'TransactionStatusUpdatedNotification':
      return NotificationCategory.transactions;
    default:
      return NotificationCategory.general;
  }
}

String labelForNotificationCategory(NotificationCategory category) {
  switch (category) {
    case NotificationCategory.tasks:
      return 'مهام';
    case NotificationCategory.complaints:
      return 'شكاوى';
    case NotificationCategory.transactions:
      return 'معاملات';
    case NotificationCategory.general:
      return 'عام';
  }
}

/// Hides redundant type chips when the title already conveys the same meaning.
bool shouldShowTypeLabel({
  required String title,
  required String type,
}) {
  final label = typeLabelForNotificationType(type);
  final normalizedTitle = title.trim();
  if (normalizedTitle.isEmpty) return true;
  if (normalizedTitle == label) return false;
  if (normalizedTitle.contains(label)) return false;

  // Common overlaps like "مهمة ميدانية جديدة" vs "مهمة ميدانية".
  if (label == 'مهمة ميدانية' && normalizedTitle.contains('مهمة ميدانية')) {
    return false;
  }
  if (label == 'تحديث شكوى' && normalizedTitle.contains('شكوى')) {
    return false;
  }
  return true;
}

/// Deep-link target for a notification based on type and user role.
String? routeForNotification(
  AppNotification notification, {
  User? user,
}) {
  final isDelegate = user?.isDelegateLike ?? false;

  switch (notification.type) {
    case 'NewTaskAssignedNotification':
      return isDelegate ? '/delegate/tasks' : null;
    case 'ComplaintStatusUpdatedNotification':
      return '/track';
    case 'TransactionStatusUpdatedNotification':
      return '/transactions';
    case 'IdentityVerificationNotification':
      return '/profile';
    case 'CitizenGeneralNotification':
    case 'BulkNotification':
      return null;
    default:
      final explicit = notification.data['route'] ??
          notification.data['url'] ??
          notification.data['path'];
      if (explicit is String && explicit.startsWith('/')) {
        return explicit;
      }
      return null;
  }
}
