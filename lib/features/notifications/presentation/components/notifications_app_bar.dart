import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const NotificationsAppBar({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
            onPressed: onBack,
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
                tooltip: 'تم الكل كمقروء',
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
}
