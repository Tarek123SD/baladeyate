import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_task_display.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_assigned_task_sheet.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_map_widgets.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateTasksScreen extends StatefulWidget {
  const DelegateTasksScreen({super.key});

  @override
  State<DelegateTasksScreen> createState() => _DelegateTasksScreenState();
}

class _DelegateTasksScreenState extends State<DelegateTasksScreen>
    with RouteAware {
  SurveyPinStatus? _statusFilter;
  bool _routeSubscribed = false;
  int? _lastShellIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final index = shell.currentIndex;
      if (index == 2 && _lastShellIndex != 2) {
        _refreshTasks();
      }
      _lastShellIndex = index;
    }

    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    final cubit = context.read<DailyTasksCubit>();
    cubit.loadPins();
    cubit.loadTasks();
  }

  Future<void> _refreshTasks() {
    final cubit = context.read<DailyTasksCubit>();
    return Future.wait([cubit.loadPins(), cubit.loadTasks()]);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _openOnMap(SurveyPin pin) async {
    context.read<DailyTasksCubit>().selectPin(pin.id);
    if (!mounted) return;
    context.go('/delegate/map');
  }

  Future<void> _clearMapSelection() async {
    context.read<DailyTasksCubit>().selectPin(null);
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final bottomClearance =
        DelegateBottomNavigationBar.clearance(context) + 16.h(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: BlocBuilder<DailyTasksCubit, DailyTasksState>(
                builder: (context, state) {
                  final filteredPins = state.filteredPins(_statusFilter);
                  final assignedTasks = state.activeAssignedTasks;
                  final isInitialLoading =
                      state.isLoadingPins && state.isLoadingTasks;

                  return RefreshIndicator(
                    color: AppColors.primaryForest,
                    onRefresh: _refreshTasks,
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
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildStatsHeader(context, state)
                                  .animate()
                                  .fadeIn(duration: 350.ms)
                                  .slideY(begin: -0.08, end: 0),
                              SizedBox(height: 16.h(context)),
                              _buildFilters(context, state),
                              if (assignedTasks.isNotEmpty) ...[
                                SizedBox(height: 20.h(context)),
                                _buildSectionHeader(
                                  context,
                                  title: 'المهام المعيّنة',
                                  count: assignedTasks.length,
                                  accent: AppColors.primaryForest,
                                ),
                                SizedBox(height: 10.h(context)),
                                ...assignedTasks.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final task = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 8.h(context),
                                    ),
                                    child: CustomDailyTaskCard(
                                      title: task.title,
                                      location:
                                          locationLabelForDelegateTask(task),
                                      statusLabel:
                                          statusLabelForDelegateTask(task),
                                      metaLabel:
                                          timeLabelForDelegateTask(task),
                                      status:
                                          cardStatusForDelegateTask(task),
                                      isPriority: task.isInProgress,
                                      emphasized: true,
                                      startLabel: task.isInProgress
                                          ? 'متابعة المهمة'
                                          : 'بدء المهمة',
                                      onTap: () =>
                                          showDelegateAssignedTaskSheet(
                                        context,
                                        task,
                                      ),
                                      onStart: task.isInProgress
                                          ? () =>
                                              showDelegateAssignedTaskSheet(
                                                context,
                                                task,
                                              )
                                          : () => context
                                              .read<DailyTasksCubit>()
                                              .updateTaskStatus(
                                                id: task.id,
                                                status: 'in_progress',
                                              ),
                                    )
                                        .animate()
                                        .fadeIn(
                                          duration: 300.ms,
                                          delay: (40 * index).ms,
                                        )
                                        .slideY(begin: 0.06, end: 0),
                                  );
                                }),
                              ],
                              SizedBox(height: 20.h(context)),
                              _buildSectionHeader(
                                context,
                                title: 'قائمة المهام',
                                count: filteredPins.length,
                                accent: AppColors.thirdForest,
                              ),
                              SizedBox(height: 10.h(context)),
                            ]),
                          ),
                        ),
                        if (isInitialLoading)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryForest,
                              ),
                            ),
                          )
                        else if (filteredPins.isEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              bottomClearance,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: _buildEmptyState(context),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              bottomClearance,
                            ),
                            sliver: SliverList.builder(
                              itemCount: filteredPins.length,
                              itemBuilder: (context, index) {
                                final pin = filteredPins[index];
                                final selected =
                                    pin.id == state.selectedPinId;
                                final distance = distanceLabelForPin(
                                  pin,
                                  state.currentPosition,
                                );
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 8.h(context),
                                  ),
                                  child: CustomDailyTaskCard(
                                    title: friendlyTitleForPin(pin),
                                    location: friendlyLocationForPin(pin),
                                    statusLabel: statusLabelForPin(pin),
                                    metaLabel: distance,
                                    status: cardStatusForPin(pin),
                                    startLabel:
                                        pin.status == SurveyPinStatus.completed
                                            ? 'عرض على الخريطة'
                                            : actionLabelForPin(pin),
                                    isSelected: selected,
                                    selectionHint: selected
                                        ? 'محددة على الخريطة — اضغط للإلغاء'
                                        : null,
                                    onTap: selected
                                        ? _clearMapSelection
                                        : () => showPinInfoSheet(
                                              context,
                                              pin,
                                            ),
                                    onStart: pin.status ==
                                            SurveyPinStatus.completed
                                        ? null
                                        : () => resumeDelegateSurvey(
                                              context,
                                              pin,
                                            ),
                                    onNavigate: () => _openOnMap(pin),
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 300.ms,
                                        delay: (40 * index).ms,
                                      )
                                      .slideY(begin: 0.06, end: 0),
                                );
                              },
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

  Widget _buildStatsHeader(BuildContext context, DailyTasksState state) {
    final progress = state.achievementRatio;
    final assignedCount = state.pins
        .where((p) => p.status == SurveyPinStatus.assigned)
        .length;
    final inProgressCount = state.pins
        .where((p) => p.status == SurveyPinStatus.inProgress)
        .length;
    final completedCount = state.pins
        .where((p) => p.status == SurveyPinStatus.completed)
        .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest,
          ],
        ),
        borderRadius: BorderRadius.circular(20.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Text(
                  'مركز المهام الميدانية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${state.completedTasks}/${state.totalTasks}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r(context)),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7.h(context),
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              color: AppColors.thirdGoldenWheat,
            ),
          ),
          SizedBox(height: 12.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _StatPill(label: 'مُسند', value: '$assignedCount'),
              SizedBox(width: 8.w(context)),
              _StatPill(label: 'قيد الإدخال', value: '$inProgressCount'),
              SizedBox(width: 8.w(context)),
              _StatPill(label: 'مكتمل', value: '$completedCount'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, DailyTasksState state) {
    final options = <(SurveyPinStatus?, String, int)>[
      (null, 'الكل', state.pins.length),
      (
        SurveyPinStatus.assigned,
        'مُسند',
        state.pins.where((p) => p.status == SurveyPinStatus.assigned).length,
      ),
      (
        SurveyPinStatus.inProgress,
        'قيد الإدخال',
        state.pins
            .where((p) => p.status == SurveyPinStatus.inProgress)
            .length,
      ),
      (
        SurveyPinStatus.completed,
        'مكتملة',
        state.pins
            .where((p) => p.status == SurveyPinStatus.completed)
            .length,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (final option in options) ...[
            _FilterChip(
              label: '${option.$2} ${option.$3}',
              selected: _statusFilter == option.$1,
              onTap: () => setState(() => _statusFilter = option.$1),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required Color accent,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 4.w(context),
          height: 18.h(context),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryForest,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '$count ${count == 1 ? 'مهمة' : 'مهام'}',
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final message = _statusFilter == null
        ? 'لا توجد مهام ميدانية بعد.'
        : 'لا توجد مهام بهذه الحالة.';
    final hint = _statusFilter == null
        ? 'ابدأ مسحاً جديداً من تبويب الخريطة.'
        : 'جرّب تغيير الفلتر لعرض مهام أخرى.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 36.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.explore_outlined,
            size: 40.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 14.h(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12.r(context)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      color: selected ? AppColors.primaryForest : Colors.white,
      borderRadius: BorderRadius.circular(20.r(context)),
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w(context),
            vertical: 9.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.primaryForest.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryForest,
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
