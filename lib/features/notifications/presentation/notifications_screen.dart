import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/presentation/components/notifications_hero_card.dart';
import 'package:baladeyate/features/notifications/utils/notification_display.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_empty_state.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_section_header.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

enum _NotificationFilter { all, unread }

enum _NotificationGroup { today, yesterday, earlier }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _NotificationFilter _filter = _NotificationFilter.all;

  @override
  void initState() {
    super.initState();
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
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
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
                        return _buildLoadingState(context, horizontalPadding);
                      }

                      if (state is NotificationsFailure) {
                        return _buildErrorState(context, state.message);
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
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                16.h(context),
                                horizontalPadding,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: NotificationsHeroCard(
                                  totalCount: loaded.notifications.length,
                                  unreadCount: loaded.unreadCount,
                                  isSubmitting: loaded.isSubmitting,
                                  onMarkAllRead: loaded.hasUnread
                                      ? () => context
                                          .read<NotificationsCubit>()
                                          .markAllAsRead()
                                      : null,
                                )
                                    .animate()
                                    .fadeIn(duration: 350.ms)
                                    .slideY(begin: -0.08, end: 0),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                18.h(context),
                                horizontalPadding,
                                8.h(context),
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _buildFilterChips(context, loaded)
                                    .animate()
                                    .fadeIn(duration: 300.ms, delay: 60.ms),
                              ),
                            ),
                            if (filtered.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  child: _buildEmptyState(context),
                                ),
                              )
                            else
                              ..._buildGroupedSlivers(
                                context,
                                filtered,
                                horizontalPadding,
                              ),
                            SliverToBoxAdapter(
                              child: SizedBox(height: 28.h(context)),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: AppColors.primaryForest.withValues(alpha: 0.12),
      automaticallyImplyLeading: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h(context)),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryForest.withValues(alpha: 0.0),
                AppColors.primaryForest.withValues(alpha: 0.12),
                AppColors.primaryForest.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
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
              Icons.arrow_forward_ios_rounded,
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
                SizedBox(height: 2.h(context)),
                Text(
                  'تنبيهاتك في مكان واحد',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
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

  Widget _buildFilterChips(
    BuildContext context,
    NotificationsLoaded state,
  ) {
    final unreadCount = state.unreadCount;

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _FilterChip(
          label: 'الكل',
          count: state.notifications.length,
          isSelected: _filter == _NotificationFilter.all,
          onTap: () => setState(() => _filter = _NotificationFilter.all),
        ),
        SizedBox(width: 10.w(context)),
        _FilterChip(
          label: 'غير مقروء',
          count: unreadCount,
          isSelected: _filter == _NotificationFilter.unread,
          highlight: unreadCount > 0,
          onTap: () => setState(() => _filter = _NotificationFilter.unread),
        ),
      ],
    );
  }

  List<AppNotification> _filteredNotifications(
    List<AppNotification> notifications,
  ) {
    if (_filter == _NotificationFilter.unread) {
      return notifications.where((n) => !n.isRead).toList();
    }
    return notifications;
  }

  List<Widget> _buildGroupedSlivers(
    BuildContext context,
    List<AppNotification> notifications,
    double horizontalPadding,
  ) {
    final groups = <_NotificationGroup, List<AppNotification>>{};
    for (final notification in notifications) {
      final group = _groupFor(notification.createdAt);
      groups.putIfAbsent(group, () => []).add(notification);
    }

    final orderedGroups = [
      _NotificationGroup.today,
      _NotificationGroup.yesterday,
      _NotificationGroup.earlier,
    ].where((g) => groups.containsKey(g));

    var animationIndex = 0;
    final slivers = <Widget>[];

    for (final group in orderedGroups) {
      final items = groups[group]!;
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            8.h(context),
            horizontalPadding,
            4.h(context),
          ),
          sliver: SliverToBoxAdapter(
            child: ProfileSectionHeader(
              title: _groupLabel(group),
              badge: '${items.length}',
            ),
          ),
        ),
      );

      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h(context)),
            itemBuilder: (context, index) {
              final notification = items[index];
              final currentIndex = animationIndex++;
              return CustomNotificationCard(
                isRead: notification.isRead,
                time: formatNotificationTime(notification.createdAt),
                title: notification.title,
                message: notificationDescription(notification),
                typeLabel: typeLabelForNotificationType(notification.type),
                icon: iconForNotificationType(notification.type),
                iconColor: iconColorForNotificationType(notification.type),
                onTap: notification.isRead
                    ? null
                    : () => context
                        .read<NotificationsCubit>()
                        .markAsRead(notification.id),
              )
                  .animate()
                  .fadeIn(
                    duration: 300.ms,
                    delay: (40 * currentIndex).ms,
                  )
                  .slideY(begin: 0.06, end: 0);
            },
          ),
        ),
      );
    }

    return slivers;
  }

  Widget _buildLoadingState(
    BuildContext context,
    double horizontalPadding,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16.h(context),
        horizontalPadding,
        24.h(context),
      ),
      children: [
        _SkeletonBox(height: 160.h(context), radius: 24.r(context)),
        SizedBox(height: 20.h(context)),
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 36.h(context), radius: 20)),
            SizedBox(width: 10.w(context)),
            Expanded(child: _SkeletonBox(height: 36.h(context), radius: 20)),
          ],
        ),
        SizedBox(height: 24.h(context)),
        for (var i = 0; i < 4; i++) ...[
          _SkeletonBox(height: 110.h(context), radius: 20.r(context)),
          SizedBox(height: 12.h(context)),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isUnreadFilter = _filter == _NotificationFilter.unread;

    return ProfileEmptyState(
      icon: isUnreadFilter
          ? Icons.mark_email_read_rounded
          : Icons.notifications_off_outlined,
      title: isUnreadFilter
          ? 'لا توجد إشعارات غير مقروءة'
          : 'لا توجد إشعارات بعد',
      description: isUnreadFilter
          ? 'رائع! لقد اطلعت على جميع التنبيهات.'
          : 'ستظهر هنا أحدث التنبيهات والتحديثات الخاصة بك.',
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileEmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'تعذّر تحميل الإشعارات',
              description: message,
            ),
            SizedBox(height: 16.h(context)),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<NotificationsCubit>().loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w(context),
                  vertical: 12.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
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

  _NotificationGroup _groupFor(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return _NotificationGroup.today;
    }

    final parsed = DateTime.tryParse(createdAt);
    if (parsed == null) {
      return _NotificationGroup.earlier;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return _NotificationGroup.today;
    if (diff == 1) return _NotificationGroup.yesterday;
    return _NotificationGroup.earlier;
  }

  String _groupLabel(_NotificationGroup group) {
    switch (group) {
      case _NotificationGroup.today:
        return 'اليوم';
      case _NotificationGroup.yesterday:
        return 'أمس';
      case _NotificationGroup.earlier:
        return 'سابقاً';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r(context)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: 14.w(context),
              vertical: 10.h(context),
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        AppColors.primaryForest,
                        AppColors.secondaryForest,
                      ],
                    )
                  : null,
              color: isSelected
                  ? null
                  : Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(20.r(context)),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : AppColors.primaryForest.withValues(alpha: 0.1),
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            AppColors.primaryForest.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.primaryForest,
                    fontSize: 13.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 6.w(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w(context),
                      vertical: 2.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : (highlight
                              ? AppColors.alertRed.withValues(alpha: 0.1)
                              : AppColors.primaryForest
                                  .withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (highlight
                                ? AppColors.alertRed
                                : AppColors.primaryForest),
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.radius,
  });

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.35),
        );
  }
}
