import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/auth/presentation/components/signup_success_dialog.dart';
import 'package:baladeyate/features/home/presentation/components/home_filter_chips.dart';
import 'package:baladeyate/features/home/presentation/components/home_heritage_section.dart';
import 'package:baladeyate/features/home/presentation/components/home_notification_update_card.dart';
import 'package:baladeyate/features/home/presentation/components/home_service_card.dart';
import 'package:baladeyate/features/home/presentation/components/home_top_section.dart';
import 'package:baladeyate/features/home/presentation/components/home_updates_empty_state.dart';
import 'package:baladeyate/features/home/presentation/components/home_updates_error_state.dart';
import 'package:baladeyate/features/home/presentation/components/home_updates_loading_state.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_state.dart';
import 'package:baladeyate/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'all';

  static const Map<String, String> _filterOptions = {
    'all': 'الكل',
    'transaction': 'المعاملات',
    'complaint': 'الشكاوى',
    'alert': 'تنبيهات',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationsCubit>().fetchNotifications();
        maybeShowPendingSignupSuccessDialog(context);
      }
    });
  }

  List<AppNotification> _filterNotifications(
    List<AppNotification> notifications,
  ) {
    if (_selectedFilter == 'all') return notifications;
    return notifications.where((notification) {
      final typeLower = notification.type.toLowerCase();
      if (_selectedFilter == 'transaction') {
        return typeLower.contains('transaction');
      }
      if (_selectedFilter == 'complaint') {
        return typeLower.contains('complaint');
      }
      if (_selectedFilter == 'alert') {
        return !typeLower.contains('transaction') &&
            !typeLower.contains('complaint');
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final paddingVal = Dimensions.pad(24, context);

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
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      paddingVal,
                      paddingVal,
                      0,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: HomeTopSection(),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: paddingVal,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.s(context),
                        crossAxisSpacing: 12.s(context),
                        childAspectRatio: 1.45,
                      ),
                      delegate: SliverChildListDelegate(
                        [
                          HomeServiceCard(
                            title: 'المعاملات والرخص',
                            icon: AppIcons.transactions,
                            onTap: () => context.go('/transactions'),
                          ),
                          HomeServiceCard(
                            title: 'الوثائق الرقمية',
                            icon: AppIcons.digitalDocs,
                            onTap: () => context.go('/profile'),
                          ),
                          HomeServiceCard(
                            title: 'تقديم شكوى',
                            icon: AppIcons.complaint,
                            onTap: () => context.push('/complains'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      32.h(context),
                      paddingVal,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SectionHeader(
                            title: 'آخر التحديثات',
                            actionText: 'عرض الكل',
                            onActionTap: () => context.push('/notifications'),
                          ),
                          SizedBox(height: 12.h(context)),
                          HomeFilterChips(
                            options: _filterOptions,
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (value) {
                              setState(() => _selectedFilter = value);
                            },
                          ),
                          SizedBox(height: 16.h(context)),
                        ],
                      ),
                    ),
                  ),
                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      if (state is NotificationsLoading) {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: paddingVal),
                          sliver: const SliverToBoxAdapter(
                            child: HomeUpdatesLoadingState(),
                          ),
                        );
                      }

                      if (state is NotificationsError) {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: paddingVal),
                          sliver: SliverToBoxAdapter(
                            child: HomeUpdatesErrorState(
                              message: state.message,
                              onRetry: () => context
                                  .read<NotificationsCubit>()
                                  .fetchNotifications(),
                            ),
                          ),
                        );
                      }

                      final notifications = state is NotificationsLoaded
                          ? state.notifications
                          : <AppNotification>[];

                      final filteredUpdates =
                          _filterNotifications(notifications);

                      if (filteredUpdates.isEmpty) {
                        return SliverPadding(
                          padding:
                              EdgeInsets.symmetric(horizontal: paddingVal),
                          sliver: const SliverToBoxAdapter(
                            child: HomeUpdatesEmptyState(),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: paddingVal),
                        sliver: SliverList.builder(
                          itemCount: filteredUpdates.length,
                          itemBuilder: (context, index) {
                            return HomeNotificationUpdateCard(
                              notification: filteredUpdates[index],
                              onActionTap: () =>
                                  context.push('/notifications'),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      paddingVal,
                      24.h(context),
                      paddingVal,
                      paddingVal,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: HomeHeritageSection(),
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
}
