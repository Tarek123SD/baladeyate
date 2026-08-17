import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_app_bar.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_category_filters.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_empty_state.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_error_state.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_grouped_slivers.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_loading_state.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_read_filters.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_unread_banner.dart';
import 'package:baladeyate/features/notifications/presentation/notification_display.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationsReadFilter _readFilter = NotificationsReadFilter.all;
  NotificationCategory? _categoryFilter;
  bool _isHandlingTap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsCubit>().loadNotifications();
      }
    });
  }

  User? get _currentUser {
    final auth = sl<AuthCubit>().state;
    return auth is AuthSuccess ? auth.user : null;
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
          AppSnackBar.showError(context, message);
        }
      },
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: NotificationsAppBar(
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(homeRouteFor(_currentUser));
              }
            },
          ),
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Dimensions.contentMaxWidth.w(context),
                  ),
                  child: BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return NotificationsLoadingState(
                          horizontalPadding: horizontalPadding,
                        );
                      }

                      if (state is NotificationsFailure) {
                        return NotificationsErrorState(
                          message: state.message,
                          onRetry: () => context
                              .read<NotificationsCubit>()
                              .loadNotifications(),
                        );
                      }

                      final loaded = state is NotificationsLoaded
                          ? state
                          : const NotificationsLoaded(notifications: []);

                      final filtered = _filteredNotifications(
                        loaded.notifications,
                      );

                      return RefreshIndicator(
                        color: AppColors.primaryForest,
                        onRefresh: () => context
                            .read<NotificationsCubit>()
                            .loadNotifications(),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            if (loaded.hasUnread)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  12.h(context),
                                  horizontalPadding,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: NotificationsUnreadBanner(
                                    unreadCount: loaded.unreadCount,
                                    isSubmitting: loaded.isSubmitting,
                                    onMarkAllRead: () => context
                                        .read<NotificationsCubit>()
                                        .markAllAsRead(),
                                  )
                                      .animate()
                                      .fadeIn(duration: 280.ms)
                                      .slideY(begin: -0.06, end: 0),
                                ),
                              ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                loaded.hasUnread
                                    ? 12.h(context)
                                    : 14.h(context),
                                horizontalPadding,
                                6.h(context),
                              ),
                              sliver: SliverToBoxAdapter(
                                child: NotificationsReadFilters(
                                  state: loaded,
                                  selected: _readFilter,
                                  onChanged: (value) =>
                                      setState(() => _readFilter = value),
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                0,
                                horizontalPadding,
                                8.h(context),
                              ),
                              sliver: SliverToBoxAdapter(
                                child: NotificationsCategoryFilters(
                                  notifications: loaded.notifications,
                                  selected: _categoryFilter,
                                  onChanged: (value) =>
                                      setState(() => _categoryFilter = value),
                                ),
                              ),
                            ),
                            if (filtered.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: NotificationsEmptyState(
                                    readFilter: _readFilter,
                                    onShowAll: () => setState(
                                      () => _readFilter =
                                          NotificationsReadFilter.all,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...NotificationsGroupedSlivers.build(
                                context: context,
                                notifications: filtered,
                                horizontalPadding: horizontalPadding,
                                onTap: _handleNotificationTap,
                                onMarkAsRead: (notification) => context
                                    .read<NotificationsCubit>()
                                    .markAsRead(notification.id),
                              ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: 24.h(context)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<AppNotification> _filteredNotifications(
    List<AppNotification> notifications,
  ) {
    return notifications.where((notification) {
      if (_readFilter == NotificationsReadFilter.unread &&
          notification.isRead) {
        return false;
      }
      if (_categoryFilter != null &&
          categoryForNotificationType(notification.type) != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _handleNotificationTap(AppNotification notification) async {
    if (_isHandlingTap) return;
    _isHandlingTap = true;

    try {
      final cubit = context.read<NotificationsCubit>();
      if (!notification.isRead) {
        await cubit.markAsRead(notification.id);
      }
      if (!mounted) return;

      openNotificationFromContext(
        context,
        notification,
        user: _currentUser,
      );
    } finally {
      _isHandlingTap = false;
    }
  }
}
