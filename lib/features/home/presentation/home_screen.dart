import 'package:baladeyate/features/auth/presentation/widgets/signup_success_dialog.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/home/presentation/components/custom_card.dart';
import 'package:baladeyate/features/home/presentation/components/greeting_card.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:baladeyate/features/home/presentation/components/update_card.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:baladeyate/features/notifications/utils/notification_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      maybeShowPendingSignupSuccessDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(Dimensions.pad(24, context)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Greeting Card
                      BlocBuilder<AuthCubit, AuthState>(
                        buildWhen: (previous, current) {
                          if (previous is AuthSuccess && current is AuthSuccess) {
                            return previous.user.name != current.user.name ||
                                previous.user.verificationStatus !=
                                    current.user.verificationStatus;
                          }
                          return previous.runtimeType != current.runtimeType;
                        },
                        builder: (context, state) {
                          final userName =
                              state is AuthSuccess ? state.user.name : 'مواطن';
                          final statusLabel = state is AuthSuccess
                              ? (state.user.verificationStatusLabel ??
                                  'حالة التوثيق غير معروفة')
                              : 'سجّل الدخول لعرض حالتك';
                          final isVerified = state is AuthSuccess &&
                              state.user.isVerified;

                          return GreetingCard(
                            greeting: 'صباح الخير',
                            name: 'أهلا بك، $userName',
                            statusLabel: statusLabel,
                            statusColor: isVerified
                                ? Colors.amber
                                : Colors.orange,
                          );
                        },
                      ),
                      SizedBox(height: 40.h(context)),
                      SizedBox(height: 40.h(context)),
                      // Quick Services
                      Column(
                        children: [
                          const SectionHeader(title: 'الخدمات السريعة'),
                          SizedBox(height: 20.h(context)),
                          _quickServiceCards(context),
                        ],
                      ),
                      SizedBox(height: 40.h(context)),
                      // Latest Updates
                      BlocBuilder<NotificationsCubit, NotificationsState>(
                        builder: (context, notificationsState) {
                          final notifications = notificationsState
                                  is NotificationsLoaded
                              ? notificationsState.notifications
                                  .take(3)
                                  .toList()
                              : const <AppNotification>[];

                          return Column(
                            children: [
                              SectionHeader(
                                title: 'آخر التحديثات',
                                actionText: 'عرض الكل',
                                onActionTap: () => context.push('/notifications'),
                              ),
                              SizedBox(height: 16.h(context)),
                              if (notificationsState is NotificationsLoading &&
                                  notifications.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (notifications.isEmpty)
                                UpdateCard(
                                  title: 'لا توجد تحديثات بعد',
                                  time: 'اليوم',
                                  description:
                                      'ستظهر هنا الإشعارات والتنبيهات الجديدة من البلدية.',
                                  icon: Icons.notifications_none_outlined,
                                  iconBgColor: AppColors.primaryForest,
                                )
                              else
                                ...notifications.map((notification) {
                                  return Padding(
                                    padding:
                                        EdgeInsets.only(bottom: 12.h(context)),
                                    child: UpdateCard(
                                      title: notification.title,
                                      time: formatNotificationTime(
                                        notification.createdAt,
                                      ),
                                      description: notificationDescription(
                                        notification,
                                      ),
                                      icon: iconForNotificationType(
                                        notification.type,
                                      ),
                                      iconBgColor: iconColorForNotificationType(
                                        notification.type,
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 40.h(context)),
                      // Heritage Section
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r(context)),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 200.h(context),
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    AppAssets.splashWallpaper,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(16.s(context)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'تراثنا، هويتنا',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                    SizedBox(height: 4.h(context)),
                                    Text(
                                      'اكتشف المزيد عن الخدمات السياحية والثقافية للمدن الأثرية بمنصة المواطن',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.white70,
                                          ),
                                      textDirection: TextDirection.rtl,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 40.h(context)),
                    ],
                  ),
                ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickServiceCards(BuildContext context) {
    final gap = 12.s(context);
    Widget tile(String title, IconData icon, {VoidCallback? onTap}) {
      return CustomCard(
        title: title,
        icon: icon,
        bgColor: Colors.white,
        iconColor: AppColors.primaryForest,
        onTap: onTap,
      );
    }

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile('تقديم شكوى', Icons.volume_up, onTap: () => context.go('/complains')),
          SizedBox(height: gap),
          tile('المتحف الثقافي', Icons.groups, onTap: _showMuseumUnavailable),
          SizedBox(height: gap),
          tile(
            'البحث في المدافن',
            Icons.search,
            onTap: () => context.push('/graves'),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: tile(
            'تقديم شكوى',
            Icons.volume_up,
            onTap: () => context.go('/complains'),
          ),
        ),
        SizedBox(width: gap),
        Expanded(child: tile('المتحف الثقافي', Icons.groups, onTap: _showMuseumUnavailable)),
        SizedBox(width: gap),
        Expanded(
          child: tile(
            'البحث في المدافن',
            Icons.search,
            onTap: () => context.push('/graves'),
          ),
        ),
      ],
    );
  }

  void _showMuseumUnavailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'المتحف الثقافي غير متصل بخدمة API حالياً. لا يوجد endpoint مخصص له في المنصة.',
        ),
      ),
    );
  }
}
