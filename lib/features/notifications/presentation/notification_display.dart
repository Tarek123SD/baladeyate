import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  switch (canonicalNotificationType(type)) {
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
    case 'GraveReservationStatusUpdatedNotification':
      return AppIcons.plotBooked;
    default:
      return AppIcons.notifInfo;
  }
}

Color iconColorForNotificationType(String type) {
  switch (canonicalNotificationType(type)) {
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
    case 'GraveReservationStatusUpdatedNotification':
      return AppColors.primaryGoldenWheat;
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
  switch (canonicalNotificationType(type)) {
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
    case 'GraveReservationStatusUpdatedNotification':
      return 'حجز قبر';
    default:
      return 'تنبيه';
  }
}

NotificationCategory categoryForNotificationType(String type) {
  switch (canonicalNotificationType(type)) {
    case 'NewTaskAssignedNotification':
      return NotificationCategory.tasks;
    case 'ComplaintStatusUpdatedNotification':
      return NotificationCategory.complaints;
    case 'TransactionStatusUpdatedNotification':
      return NotificationCategory.transactions;
    case 'GraveReservationStatusUpdatedNotification':
      return NotificationCategory.general;
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

/// Deep-link target for a notification based on type, payload, and user role.
String? routeForNotification(
  AppNotification notification, {
  User? user,
}) {
  final isDelegate = user?.isDelegateLike ?? false;

  switch (canonicalNotificationType(notification.type)) {
    case 'NewTaskAssignedNotification':
      if (!isDelegate) return homeRouteFor(user);
      final txId = _relatedNumericId(notification.data, const [
        'transaction_id',
        'transactionId',
      ]);
      if (txId != null) return '/delegate/transactions';
      return '/delegate/tasks';
    case 'ComplaintStatusUpdatedNotification':
      return isDelegate ? '/delegate/tasks' : '/track';
    case 'TransactionStatusUpdatedNotification':
      if (isDelegate) return '/delegate/transactions';
      final id = _relatedNumericId(notification.data, const [
        'transaction_id',
        'transactionId',
        'id',
      ]);
      if (id != null) return '/transactions/$id';
      return '/transactions';
    case 'IdentityVerificationNotification':
      if (isDelegate) return homeRouteFor(user);
      final status = (notification.data['status'] ??
              notification.data['verification_status'] ??
              user?.verificationStatus)
          ?.toString()
          .toLowerCase();
      if (status == 'rejected' ||
          status == 'unverified' ||
          (user?.canSubmitVerification ?? false)) {
        return '/verify-identity';
      }
      return '/profile';
    case 'CitizenGeneralNotification':
    case 'BulkNotification':
      return _explicitRoute(notification.data) ?? homeRouteFor(user);
    case 'GraveReservationStatusUpdatedNotification':
      if (isDelegate) return homeRouteFor(user);
      return '/cemetery/reservations';
    default:
      return _explicitRoute(notification.data) ?? homeRouteFor(user);
  }
}

/// Opens [route] with `go` for shell tabs (and splash) and `push` otherwise.
void openNotificationRoute(GoRouter router, String route) {
  if (route.isEmpty) return;
  final path = Uri.tryParse(route)?.path ?? route;
  final current = router.routerDelegate.currentConfiguration.uri.path;
  final replaceStack =
      current.isEmpty || current == '/splash' || current == '/login';
  if (replaceStack || isIndexedShellTabRoute(path)) {
    router.go(route);
  } else {
    router.push(route);
  }
}

/// Resolves and opens the destination for [notification] from a widget.
void openNotificationFromContext(
  BuildContext context,
  AppNotification notification, {
  User? user,
}) {
  final route = routeForNotification(notification, user: user);
  if (route == null) return;
  openNotificationRoute(GoRouter.of(context), route);
}

String? _explicitRoute(Map<String, dynamic> data) {
  for (final key in const ['route', 'url', 'path', 'click_action']) {
    final value = data[key];
    if (value is String && value.startsWith('/')) {
      return value;
    }
  }
  return null;
}

String? _relatedNumericId(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final raw = data[key];
    if (raw == null) continue;
    final text = raw.toString().trim();
    if (text.isEmpty || text == 'null') continue;
    if (int.tryParse(text) != null) return text;
  }
  return null;
}
