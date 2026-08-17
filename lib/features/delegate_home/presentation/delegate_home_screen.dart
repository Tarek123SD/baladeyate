import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/delegate_home/presentation/components/delegate_home_greeting.dart';
import 'package:baladeyate/features/delegate_home/presentation/components/delegate_home_priority_tasks.dart';
import 'package:baladeyate/features/delegate_home/presentation/components/delegate_home_progress_row.dart';
import 'package:baladeyate/features/delegate_home/presentation/components/delegate_home_quick_actions.dart';
import 'package:baladeyate/features/delegate_home/presentation/components/delegate_home_recent_activity.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeScreen extends StatefulWidget {
  const DelegateHomeScreen({super.key});

  @override
  State<DelegateHomeScreen> createState() => _DelegateHomeScreenState();
}

class _DelegateHomeScreenState extends State<DelegateHomeScreen> {
  int? _lastShellIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final index = shell.currentIndex;
      if (index == DelegateShellIndices.home &&
          _lastShellIndex != DelegateShellIndices.home) {
        if (mounted) {
          context.read<DailyTasksCubit>().refreshDashboard();
        }
      }
      _lastShellIndex = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = Dimensions.pad(24, context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: BlocBuilder<DailyTasksCubit, DailyTasksState>(
                builder: (context, tasksState) {
                  final bottomClearance =
                      DelegateBottomNavigationBar.clearance(context) +
                          16.h(context);
                  return RefreshIndicator(
                    color: AppColors.primaryForest,
                    onRefresh: () =>
                        context.read<DailyTasksCubit>().refreshDashboard(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            horizontalPadding,
                            horizontalPadding,
                            bottomClearance,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              const DelegateHomeGreeting(),
                              SizedBox(height: 24.h(context)),
                              DelegateHomeProgressRow(state: tasksState),
                              SizedBox(height: 28.h(context)),
                              const SectionHeader(title: 'الوصول السريع'),
                              SizedBox(height: 16.h(context)),
                              const DelegateHomeQuickActions(),
                              SizedBox(height: 28.h(context)),
                              SectionHeader(
                                title: 'مهام ذات أولوية',
                                actionText: 'عرض الكل',
                                onActionTap: () =>
                                    context.go('/delegate/tasks'),
                              ),
                              SizedBox(height: 16.h(context)),
                              DelegateHomePriorityTasks(state: tasksState),
                              SizedBox(height: 28.h(context)),
                              const SectionHeader(title: 'آخر النشاط'),
                              SizedBox(height: 16.h(context)),
                              DelegateHomeRecentActivity(state: tasksState),
                            ]),
                          ),
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
    );
  }
}
