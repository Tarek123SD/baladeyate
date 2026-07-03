import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsCubit>()..loadNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocListener<NotificationsCubit, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundWhite),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 4,
            automaticallyImplyLeading: false,
            title: Row(
              textDirection: TextDirection.rtl,
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/main');
                    }
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryForest,
                    size: 20.ic(context),
                  ),
                  padding: EdgeInsets.zero,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الإشعارات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 20.f(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        'يمكنك متابعة أحدث التنبيهات هنا',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF6D6D6D),
                          fontSize: 12.f(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 48.s(context)),
              ],
            ),
          ),
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationsFailure &&
                      state is! NotificationsLoaded) {
                    return Center(
                      child: TextButton(
                        onPressed: () =>
                            context.read<NotificationsCubit>().loadNotifications(),
                        child: const Text('إعادة المحاولة'),
                      ),
                    );
                  }

                  final notifications = state is NotificationsLoaded
                      ? state.notifications
                      : <AppNotification>[];

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<NotificationsCubit>().loadNotifications(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 18.h(context),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                if (notifications.isNotEmpty)
                                  GestureDetector(
                                    onTap: state is NotificationsLoaded &&
                                            !state.isSubmitting
                                        ? () => context
                                            .read<NotificationsCubit>()
                                            .markAllAsRead()
                                        : null,
                                    child: Text(
                                      'تحديد الكل كمقروء',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: AppColors.primaryGoldenWheat,
                                        fontSize: 14.f(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  'الإشعارات',
                                  style: TextStyle(
                                    color: AppColors.primaryForest,
                                    fontSize: 14.f(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 22.h(context)),
                            if (notifications.isEmpty)
                              _buildEmptyState(context)
                            else
                              ...notifications.map(
                                (notification) => Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 18.h(context)),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!notification.isRead) {
                                        context
                                            .read<NotificationsCubit>()
                                            .markAsRead(notification.id);
                                      }
                                    },
                                    child: Opacity(
                                      opacity:
                                          notification.isRead ? 0.65 : 1,
                                      child: CustomNotificationCard(
                                        time: _formatTime(
                                          notification.createdAt,
                                        ),
                                        title: notification.title,
                                        message: notification.message,
                                        icon: _iconForType(notification.type),
                                        iconColor:
                                            _iconColorForType(notification.type),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 20.h(context)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h(context)),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48.ic(context),
              color: const Color(0xFF9A9A9A),
            ),
            SizedBox(height: 14.h(context)),
            Text(
              'لا توجد إشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF9A9A9A),
                fontSize: 14.f(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? createdAt) {
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

  IconData _iconForType(String type) {
    switch (type) {
      case 'ComplaintStatusUpdatedNotification':
        return Icons.report_outlined;
      case 'NewTaskAssignedNotification':
        return Icons.assignment_outlined;
      case 'CitizenGeneralNotification':
        return Icons.family_restroom;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'ComplaintStatusUpdatedNotification':
        return AppColors.primaryForest;
      case 'NewTaskAssignedNotification':
        return AppColors.primaryGoldenWheat;
      case 'CitizenGeneralNotification':
        return AppColors.secondaryForest;
      default:
        return AppColors.green;
    }
  }
}
