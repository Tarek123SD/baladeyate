import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_task_display.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_assigned_task_sheet.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_map_widgets.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/features/home/presentation/components/custom_card.dart';
import 'package:baladeyate/features/home/presentation/components/greeting_card.dart';
import 'package:baladeyate/features/home/presentation/components/section_header.dart';
import 'package:baladeyate/features/home/presentation/components/update_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeScreen extends StatefulWidget {
  const DelegateHomeScreen({super.key});

  @override
  State<DelegateHomeScreen> createState() => _DelegateHomeScreenState();

  Widget _buildGreeting(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.name != current.user.name;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, state) {
        final userName = state is AuthSuccess ? state.user.name : 'مندوب';
        return GreetingCard(
          greeting: _timeGreeting(),
          name: 'أهلاً، $userName',
          statusLabel: 'مندوب ميداني',
          statusColor: AppColors.primaryGoldenWheat,
        );
      },
    );
  }

  Widget _buildProgressRow(BuildContext context, DailyTasksState state) {
    return Column(
      children: [
        Row(
          textDirection: TextDirection.rtl,
          children: [
            CustomTrackStatisticCard(
              title: 'إجمالي المهام',
              value: '${state.totalTasks}',
              backgroundColor: Colors.white,
              textColor: AppColors.primaryForest,
            ),
            SizedBox(width: 10.w(context)),
            CustomTrackStatisticCard(
              title: 'قيد التنفيذ',
              value: '${state.inProgressTasks}',
              backgroundColor:
                  AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
              textColor: AppColors.primaryForest,
            ),
          ],
        ),
        SizedBox(height: 10.h(context)),
        Row(
          textDirection: TextDirection.rtl,
          children: [
            CustomTrackStatisticCard(
              title: 'مكتملة',
              value: '${state.completedTasks}',
              backgroundColor: AppColors.secondaryForest.withValues(alpha: 0.15),
              textColor: AppColors.primaryForest,
            ),
            SizedBox(width: 10.w(context)),
            CustomTrackStatisticCard(
              title: 'الإنجاز',
              value: '${state.achievementPercent}%',
              backgroundColor:
                  AppColors.thirdGoldenWheat.withValues(alpha: 0.75),
              textColor: AppColors.primaryGoldenWheat,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final gap = 12.s(context);

    Widget tile(String title, IconData icon, VoidCallback onTap) {
      return CustomCard(
        title: title,
        icon: icon,
        bgColor: Colors.white,
        iconColor: AppColors.primaryForest,
        onTap: onTap,
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: tile(
                'الخريطة',
                Icons.map_rounded,
                () => context.push('/delegate/map'),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: tile(
                'المهام',
                Icons.assignment_rounded,
                () => context.push('/delegate/tasks'),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              child: tile(
                'فحص الوثائق',
                Icons.qr_code_scanner_rounded,
                () => context.push('/delegate/home/verify-document'),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: tile(
                'خريطة المقبرة',
                Icons.park_rounded,
                () => context.push('/delegate/cemetery-map'),
              ),
            ),
          ],
        ),
      ],
    );
  }



  List<Widget> _buildPriorityTasks(
    BuildContext context,
    DailyTasksState state,
  ) {
    final assignedTasks = state.activeAssignedTasks.take(2).toList();
    final priorityPins = state.pins
        .where(
          (pin) =>
              pin.status == SurveyPinStatus.assigned ||
              pin.status == SurveyPinStatus.inProgress,
        )
        .take(3 - assignedTasks.length)
        .toList();

    if (assignedTasks.isEmpty && priorityPins.isEmpty) {
      return [
        Container(
          padding: EdgeInsets.all(20.s(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            'لا توجد مهام نشطة حالياً. ابدأ مسحاً جديداً من الخريطة.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              fontSize: 14.f(context),
            ),
          ),
        ),
      ];
    }

    final widgets = <Widget>[];

    for (final task in assignedTasks) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h(context)),
          child: CustomDailyTaskCard(
            title: task.title,
            location: locationLabelForDelegateTask(task),
            distance: statusLabelForDelegateTask(task),
            time: timeLabelForDelegateTask(task),
            status: cardStatusForDelegateTask(task),
            startLabel:
                task.isInProgress ? 'متابعة المهمة' : 'بدء المهمة',
            onTap: () => showDelegateAssignedTaskSheet(context, task),
            onStart: task.isInProgress
                ? () => showDelegateAssignedTaskSheet(context, task)
                : () => context.read<DailyTasksCubit>().updateTaskStatus(
                      id: task.id,
                      status: 'in_progress',
                    ),
            onInfo: () => showDelegateAssignedTaskSheet(context, task),
          ),
        ),
      );
    }

    for (final pin in priorityPins) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h(context)),
          child: CustomDailyTaskCard(
            title: pin.displayTitle,
            location: pin.displayLocation,
            distance: statusLabelForPin(pin),
            time: pin.status == SurveyPinStatus.completed ? 'محفوظ' : 'مفتوح',
            status: cardStatusForPin(pin),
            startLabel: pin.status == SurveyPinStatus.inProgress
                ? 'متابعة المهمة'
                : 'بدء المهمة',
            onTap: () {
              context.read<DailyTasksCubit>().selectPin(pin.id);
              context.go('/delegate/map');
            },
            onStart: () => resumeDelegateSurvey(context, pin),
            onNavigate: () {
              context.read<DailyTasksCubit>().selectPin(pin.id);
              context.go('/delegate/map');
            },
            onInfo: () => showPinInfoSheet(context, pin),
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildRecentActivity(
    BuildContext context,
    DailyTasksState state,
  ) {
    final completedTasks = completedDelegateTasks(state.delegateTasks).take(1);
    final completed = state.pins
        .where((pin) => pin.status == SurveyPinStatus.completed)
        .take(2 - completedTasks.length)
        .toList();

    if (completedTasks.isEmpty && completed.isEmpty) {
      return [
        UpdateCard(
          title: 'لا يوجد نشاط مكتمل بعد',
          time: 'اليوم',
          description: 'ستظهر هنا المهام المكتملة بعد إنهاء المسوحات الميدانية.',
          icon: Icons.assignment_turned_in_outlined,
          iconBgColor: AppColors.primaryForest,
        ),
      ];
    }

    final widgets = <Widget>[];

    for (final task in completedTasks) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h(context)),
          child: UpdateCard(
            title: 'اكتملت مهمة: ${task.title}',
            time: 'مكتمل',
            description: locationLabelForDelegateTask(task),
            icon: Icons.check_circle_outline,
            iconBgColor: AppColors.primaryForest,
          ),
        ),
      );
    }

    for (final pin in completed) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h(context)),
          child: UpdateCard(
            title: 'اكتمل مسح: ${pin.displayTitle}',
            time: 'مكتمل',
            description: pin.displayLocation,
            icon: Icons.check_circle_outline,
            iconBgColor: AppColors.primaryForest,
          ),
        ),
      );
    }

    return widgets;
  }

  String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مساء الخير';
    return 'مساء الخير';
  }
}

class _DelegateHomeScreenState extends State<DelegateHomeScreen> {
  int? _lastShellIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final index = shell.currentIndex;
      if (index == 0 && _lastShellIndex != 0) {
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: BlocBuilder<DailyTasksCubit, DailyTasksState>(
                builder: (context, tasksState) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.all(horizontalPadding),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            widget._buildGreeting(context),
                            SizedBox(height: 24.h(context)),
                            widget._buildProgressRow(context, tasksState),
                            SizedBox(height: 28.h(context)),
                            const SectionHeader(title: 'الوصول السريع'),
                            SizedBox(height: 16.h(context)),
                            widget._buildQuickActions(context),
                            SizedBox(height: 28.h(context)),
                            SectionHeader(
                              title: 'مهام ذات أولوية',
                              actionText: 'عرض الكل',
                              onActionTap: () => context.go('/delegate/tasks'),
                            ),
                            SizedBox(height: 16.h(context)),
                            ...widget._buildPriorityTasks(context, tasksState),
                            SizedBox(height: 28.h(context)),
                            const SectionHeader(title: 'آخر النشاط'),
                            SizedBox(height: 16.h(context)),
                            ...widget._buildRecentActivity(context, tasksState),
                            SizedBox(height: 24.h(context)),
                          ]),
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

}
