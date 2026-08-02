import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.showSettings = true,
    this.showNotifications = true,
    this.showBackButton = false,
  });

  final bool showSettings;
  final bool showNotifications;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.s(context);
    final logoHeight = kToolbarHeight - 16;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      titleSpacing: 8.w(context),
      title: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (showBackButton || context.canPop())
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
                AppIcons.back,
                color: AppColors.primaryForest,
                size: 20.s(context),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 36.w(context),
                minHeight: 36.w(context),
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                AppAssets.logoHorizontalDarkGreen,
                height: logoHeight,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          if (showNotifications)
            _NotificationsButton(iconSize: iconSize),
          if (showSettings)
            IconButton(
              onPressed: () {
                context.push('/settings');
              },
              icon: Icon(
                AppIcons.settings,
                color: Colors.black87,
                size: iconSize,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: 36.w(context),
                minHeight: 36.w(context),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bell icon that surfaces the number of unread notifications as a badge.
class _NotificationsButton extends StatelessWidget {
  const _NotificationsButton({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      buildWhen: (previous, current) {
        final previousCount =
            previous is NotificationsLoaded ? previous.unreadCount : 0;
        final currentCount =
            current is NotificationsLoaded ? current.unreadCount : 0;
        return previousCount != currentCount;
      },
      builder: (context, state) {
        final unreadCount =
            state is NotificationsLoaded ? state.unreadCount : 0;
        final hasUnread = unreadCount > 0;
        final badgeLabel = unreadCount > 99 ? '99+' : '$unreadCount';

        return IconButton(
          onPressed: () => context.push('/notifications'),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 36.w(context),
            minHeight: 36.w(context),
          ),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                hasUnread
                    ? AppIcons.notificationActive
                    : AppIcons.notification,
                color: hasUnread ? AppColors.primaryForest : Colors.black87,
                size: iconSize,
              ),
              if (hasUnread)
                Positioned(
                  top: -4.h(context),
                  right: -4.w(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w(context),
                      vertical: 1.h(context),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w(context),
                      minHeight: 16.w(context),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      shape: badgeLabel.length > 1
                          ? BoxShape.rectangle
                          : BoxShape.circle,
                      borderRadius: badgeLabel.length > 1
                          ? BorderRadius.circular(9.r(context))
                          : null,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.f(context),
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
