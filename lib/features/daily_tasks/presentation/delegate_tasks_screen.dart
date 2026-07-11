import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Dimensions.contentMaxWidth.w(context),
            ),
            child: BlocBuilder<DailyTasksCubit, DailyTasksState>(
              builder: (context, state) {
                final filteredPins = state.filteredPins(_statusFilter);
                final assignedTasks = state.activeAssignedTasks;

                return RefreshIndicator(
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
                            Text(
                              'المهام الميدانية',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontSize: 22.f(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 16.h(context)),
                            Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                CustomTrackStatisticCard(
                                  title: 'الإجمالي',
                                  value: '${state.totalTasks}',
                                  backgroundColor: Colors.white,
                                  textColor: AppColors.primaryForest,
                                ),
                                SizedBox(width: 10.w(context)),
                                CustomTrackStatisticCard(
                                  title: 'قيد التنفيذ',
                                  value: '${state.inProgressTasks}',
                                  backgroundColor: AppColors.thirdGoldenWheat
                                      .withValues(alpha: 0.35),
                                  textColor: AppColors.primaryForest,
                                ),
                                SizedBox(width: 10.w(context)),
                                CustomTrackStatisticCard(
                                  title: 'الإنجاز',
                                  value: '${state.achievementPercent}%',
                                  backgroundColor: AppColors.thirdGoldenWheat
                                      .withValues(alpha: 0.75),
                                  textColor: AppColors.primaryGoldenWheat,
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h(context)),
                            _FilterChips(
                              selected: _statusFilter,
                              onSelected: (filter) {
                                setState(() => _statusFilter = filter);
                              },
                            ),
                            if (assignedTasks.isNotEmpty) ...[
                              SizedBox(height: 20.h(context)),
                              Text(
                                'المهام المعيّنة',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.primaryForest,
                                  fontSize: 16.f(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 12.h(context)),
                              ...assignedTasks.map((task) {
                                return Padding(
                                  padding:
                                      EdgeInsets.only(bottom: 14.h(context)),
                                  child: CustomDailyTaskCard(
                                    title: task.title,
                                    location: locationLabelForDelegateTask(task),
                                    distance: statusLabelForDelegateTask(task),
                                    time: timeLabelForDelegateTask(task),
                                    status: cardStatusForDelegateTask(task),
                                    onTap: () => showDelegateAssignedTaskSheet(
                                      context,
                                      task,
                                    ),
                                    onStart: task.isInProgress
                                        ? () => showDelegateAssignedTaskSheet(
                                              context,
                                              task,
                                            )
                                        : () => context
                                            .read<DailyTasksCubit>()
                                            .updateTaskStatus(
                                              id: task.id,
                                              status: 'in_progress',
                                            ),
                                    onInfo: () => showDelegateAssignedTaskSheet(
                                      context,
                                      task,
                                    ),
                                  ),
                                );
                              }),
                            ],
                            SizedBox(height: 20.h(context)),
                            Text(
                              'مسوحاتي الميدانية',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontSize: 16.f(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 16.h(context)),
                          ]),
                        ),
                      ),
                      if (state.isLoadingPins && state.isLoadingTasks)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (filteredPins.isEmpty)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 48.h(context),
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              _statusFilter == null
                                  ? 'لا توجد مهام ميدانية بعد.'
                                  : 'لا توجد مهام بهذه الحالة.',
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.7),
                                fontSize: 14.f(context),
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            0,
                            horizontalPadding,
                            24.h(context),
                          ),
                          sliver: SliverList.builder(
                            itemCount: filteredPins.length,
                            itemBuilder: (context, index) {
                              final pin = filteredPins[index];
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: 14.h(context)),
                                child: CustomDailyTaskCard(
                                  title: pin.displayTitle,
                                  location: pin.displayLocation,
                                  distance: statusLabelForPin(pin),
                                  time: pin.status == SurveyPinStatus.completed
                                      ? 'محفوظ'
                                      : 'مفتوح',
                                  status: cardStatusForPin(pin),
                                  isSelected: pin.id == state.selectedPinId,
                                  onTap: () => _openOnMap(pin),
                                  onStart: () => resumeDelegateSurvey(
                                    context,
                                    pin,
                                  ),
                                  onNavigate: () => _openOnMap(pin),
                                  onInfo: () => showPinInfoSheet(context, pin),
                                ),
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
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelected,
  });

  final SurveyPinStatus? selected;
  final ValueChanged<SurveyPinStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w(context),
      runSpacing: 8.h(context),
      textDirection: TextDirection.rtl,
      children: [
        _Chip(
          label: 'الكل',
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        _Chip(
          label: 'قيد التنفيذ',
          isSelected: selected == SurveyPinStatus.inProgress,
          onTap: () => onSelected(SurveyPinStatus.inProgress),
        ),
        _Chip(
          label: 'مكتملة',
          isSelected: selected == SurveyPinStatus.completed,
          onTap: () => onSelected(SurveyPinStatus.completed),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
      checkmarkColor: AppColors.primaryForest,
      labelStyle: TextStyle(
        color: AppColors.primaryForest,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13.f(context),
      ),
      side: BorderSide(
        color: AppColors.secondaryCharcoal.withValues(alpha: 0.2),
      ),
    );
  }
}
