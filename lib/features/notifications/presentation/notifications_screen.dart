import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Always refresh when the screen opens so the list and badge stay in sync.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsCubit>().loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocListener<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) {
        if (current is NotificationsFailure) return true;
        return current is NotificationsLoaded && current.actionError != null;
      },
      listener: (context, state) {
        String? message;
        if (state is NotificationsFailure) {
          message = state.message;
        } else if (state is NotificationsLoaded) {
          message = state.actionError;
          context.read<NotificationsCubit>().clearActionError();
        }
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
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
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocBuilder<NotificationsCubit, NotificationsState>(
                builder: (context, state) {
                  if (state is NotificationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationsFailure) {
                    return _buildErrorState(context, state.message);
                  }

                  final loaded = state is NotificationsLoaded
                      ? state
                      : const NotificationsLoaded(notifications: []);

                  return Column(
                    children: [
                      _buildSummaryBar(context, loaded, horizontalPadding),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primaryForest,
                          onRefresh: () => context
                              .read<NotificationsCubit>()
                              .loadNotifications(),
                          child: loaded.notifications.isEmpty
                              ? _buildEmptyState(context)
                              : _buildList(
                                  context,
                                  loaded.notifications,
                                  horizontalPadding,
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
                final authState = sl<AuthCubit>().state;
                final home = authState is AuthSuccess
                    ? homeRouteFor(authState.user)
                    : '/login';
                context.go(home);
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
    );
  }

  Widget _buildSummaryBar(
    BuildContext context,
    NotificationsLoaded state,
    double horizontalPadding,
  ) {
    final unreadCount = state.unreadCount;
    final hasUnread = unreadCount > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16.h(context),
        horizontalPadding,
        10.h(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasUnread
                  ? 'لديك $unreadCount ${_unreadLabel(unreadCount)} غير مقروء'
                  : state.notifications.isEmpty
                      ? 'لا توجد إشعارات'
                      : 'جميع الإشعارات مقروءة',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 14.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (hasUnread)
            TextButton.icon(
              onPressed: () =>
                  context.read<NotificationsCubit>().markAllAsRead(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryGoldenWheat,
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 4.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
              ),
              icon: Icon(
                Icons.done_all_rounded,
                size: 18.ic(context),
                color: AppColors.primaryGoldenWheat,
              ),
              label: Text(
                'تحديد الكل كمقروء',
                style: TextStyle(
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<AppNotification> notifications,
    double horizontalPadding,
  ) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        6.h(context),
        horizontalPadding,
        24.h(context),
      ),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return CustomNotificationCard(
          isRead: notification.isRead,
          time: _formatTime(notification.createdAt),
          title: notification.title,
          message: notification.message,
          icon: _iconForType(notification.type),
          iconColor: _iconColorForType(notification.type),
          onTap: notification.isRead
              ? null
              : () => context
                  .read<NotificationsCubit>()
                  .markAsRead(notification.id),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(22.s(context)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 46.ic(context),
                      color: AppColors.primaryForest.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'لا توجد إشعارات بعد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 16.f(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    'ستظهر هنا أحدث التنبيهات الخاصة بك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontSize: 13.f(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 46.ic(context),
              color: const Color(0xFF9A9A9A),
            ),
            SizedBox(height: 14.h(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF5B5B5B),
                fontSize: 14.f(context),
              ),
            ),
            SizedBox(height: 16.h(context)),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<NotificationsCubit>().loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.ic(context)),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  String _unreadLabel(int count) {
    if (count == 1) return 'إشعار';
    if (count == 2) return 'إشعارين';
    if (count <= 10) return 'إشعارات';
    return 'إشعارًا';
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
    if (diff.inMinutes < 1) {
      return 'الآن';
    }
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
