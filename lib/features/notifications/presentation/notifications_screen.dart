import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/utils/notification_display.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_empty_state.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_section_header.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

enum _ReadFilter { all, unread }

enum _NotificationGroup { today, yesterday, earlier }

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _ReadFilter _readFilter = _ReadFilter.all;
  NotificationCategory? _categoryFilter;

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
                            if (loaded.hasUnread)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  12.h(context),
                                  horizontalPadding,
                                  0,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _UnreadBanner(
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
                                loaded.hasUnread ? 12.h(context) : 14.h(context),
                                horizontalPadding,
                                6.h(context),
                              ),
                              sliver: SliverToBoxAdapter(
                                child: _buildReadFilters(context, loaded),
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
                                child: _buildCategoryFilters(
                                  context,
                                  loaded.notifications,
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      automaticallyImplyLeading: false,
      title: Row(
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                final home = homeRouteFor(_currentUser);
                context.go(home);
              }
            },
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryForest,
              size: 18.ic(context),
            ),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Text(
              'الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 18.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded && state.hasUnread;
              if (!hasUnread) {
                return SizedBox(width: 40.s(context));
              }
              return IconButton(
                tooltip: 'تعليم الكل كمقروء',
                onPressed: () =>
                    context.read<NotificationsCubit>().markAllAsRead(),
                icon: Icon(
                  Icons.done_all_rounded,
                  color: AppColors.primaryForest,
                  size: 22.ic(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReadFilters(
    BuildContext context,
    NotificationsLoaded state,
  ) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _FilterChip(
          label: 'الكل',
          count: state.notifications.length,
          isSelected: _readFilter == _ReadFilter.all,
          onTap: () => setState(() => _readFilter = _ReadFilter.all),
        ),
        SizedBox(width: 8.w(context)),
        _FilterChip(
          label: 'غير مقروء',
          count: state.unreadCount,
          isSelected: _readFilter == _ReadFilter.unread,
          highlight: state.unreadCount > 0,
          onTap: () => setState(() => _readFilter = _ReadFilter.unread),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(
    BuildContext context,
    List<AppNotification> notifications,
  ) {
    final counts = <NotificationCategory, int>{};
    for (final item in notifications) {
      final category = categoryForNotificationType(item.type);
      counts[category] = (counts[category] ?? 0) + 1;
    }

    final available = NotificationCategory.values
        .where((category) => (counts[category] ?? 0) > 0)
        .toList();

    if (available.length <= 1) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _TypeChip(
            label: 'كل الأنواع',
            selected: _categoryFilter == null,
            onTap: () => setState(() => _categoryFilter = null),
          ),
          SizedBox(width: 8.w(context)),
          for (final category in available) ...[
            _TypeChip(
              label:
                  '${labelForNotificationCategory(category)} ${counts[category]}',
              selected: _categoryFilter == category,
              onTap: () => setState(() => _categoryFilter = category),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }

  List<AppNotification> _filteredNotifications(
    List<AppNotification> notifications,
  ) {
    return notifications.where((notification) {
      if (_readFilter == _ReadFilter.unread && notification.isRead) {
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
    final cubit = context.read<NotificationsCubit>();
    if (!notification.isRead) {
      await cubit.markAsRead(notification.id);
    }
    if (!mounted) return;

    final route = routeForNotification(notification, user: _currentUser);
    if (route != null) {
      context.push(route);
    }
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
            6.h(context),
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
            separatorBuilder: (_, __) => SizedBox(height: 8.h(context)),
            itemBuilder: (context, index) {
              final notification = items[index];
              final currentIndex = animationIndex++;
              final typeLabel = shouldShowTypeLabel(
                title: notification.title,
                type: notification.type,
              )
                  ? typeLabelForNotificationType(notification.type)
                  : null;

              final card = CustomNotificationCard(
                isRead: notification.isRead,
                time: formatNotificationTime(notification.createdAt),
                title: notification.title,
                message: notificationDescription(notification),
                typeLabel: typeLabel,
                icon: iconForNotificationType(notification.type),
                iconColor: iconColorForNotificationType(notification.type),
                onTap: () => _handleNotificationTap(notification),
              );

              return Dismissible(
                key: ValueKey('notification-${notification.id}'),
                direction: notification.isRead
                    ? DismissDirection.none
                    : DismissDirection.startToEnd,
                confirmDismiss: (_) async {
                  await context
                      .read<NotificationsCubit>()
                      .markAsRead(notification.id);
                  return false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryForest.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Icon(
                        Icons.done_rounded,
                        color: AppColors.primaryForest,
                        size: 18.ic(context),
                      ),
                      SizedBox(width: 6.w(context)),
                      Text(
                        'تعليم كمقروء',
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                child: card
                    .animate()
                    .fadeIn(
                      duration: 260.ms,
                      delay: (30 * currentIndex).ms,
                    )
                    .slideY(begin: 0.04, end: 0),
              );
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
        _SkeletonBox(height: 44.h(context), radius: 12.r(context)),
        SizedBox(height: 14.h(context)),
        Row(
          children: [
            Expanded(child: _SkeletonBox(height: 34.h(context), radius: 18)),
            SizedBox(width: 8.w(context)),
            Expanded(child: _SkeletonBox(height: 34.h(context), radius: 18)),
          ],
        ),
        SizedBox(height: 18.h(context)),
        for (var i = 0; i < 5; i++) ...[
          _SkeletonBox(height: 78.h(context), radius: 14.r(context)),
          SizedBox(height: 8.h(context)),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isUnreadFilter = _readFilter == _ReadFilter.unread;

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
            onPressed: () => setState(() => _readFilter = _ReadFilter.all),
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

    final parsed = DateTime.tryParse(createdAt)?.toLocal();
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

class _UnreadBanner extends StatelessWidget {
  const _UnreadBanner({
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
                    'تعليم الكل',
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
          borderRadius: BorderRadius.circular(18.r(context)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 8.h(context),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryForest : Colors.white,
              borderRadius: BorderRadius.circular(18.r(context)),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryForest
                    : AppColors.primaryForest.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryForest,
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 5.w(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w(context),
                      vertical: 1.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : (highlight
                              ? AppColors.alertRed.withValues(alpha: 0.1)
                              : AppColors.primaryForest
                                  .withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10.r(context)),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (highlight
                                ? AppColors.alertRed
                                : AppColors.primaryForest),
                        fontSize: 10.f(context),
                        fontWeight: FontWeight.w800,
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.thirdForest.withValues(alpha: 0.16)
          : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 7.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.thirdForest.withValues(alpha: 0.45)
                  : AppColors.primaryForest.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.secondaryCharcoal.withValues(alpha: 0.8),
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
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
