import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_assigned_task_sheet.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_widgets.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/tasks_empty_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/tasks_section_header.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/tasks_stats_header.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/tasks_status_filters.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_task_display.dart';
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
      if (index == DelegateShellIndices.tasks &&
          _lastShellIndex != DelegateShellIndices.tasks) {
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
                              TasksStatsHeader(state: state)
                                  .animate()
                                  .fadeIn(duration: 350.ms)
                                  .slideY(begin: -0.08, end: 0),
                              SizedBox(height: 16.h(context)),
                              TasksStatusFilters(
                                state: state,
                                selected: _statusFilter,
                                onSelected: (status) =>
                                    setState(() => _statusFilter = status),
                              ),
                              if (assignedTasks.isNotEmpty) ...[
                                SizedBox(height: 20.h(context)),
                                TasksSectionHeader(
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
                              TasksSectionHeader(
                                title: 'قائمة المهام',
                                count: filteredPins.length,
                                accent: AppColors.thirdForest,
                              ),
                              SizedBox(height: 10.h(context)),
                            ]),
                          ),
                        ),
                        if (isInitialLoading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.pageProgress(context),
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
                              child: TasksEmptyState(
                                hasStatusFilter: _statusFilter != null,
                              ),
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
}
