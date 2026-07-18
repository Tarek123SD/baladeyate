import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/custom_track_filter_button.dart';
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
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => context.go('/delegate/map'),
        backgroundColor: AppColors.green,
        icon: const Icon(Icons.map_rounded, color: AppColors.thirdGoldenWheat),
        label: Text(
          'الخريطة',
          style: TextStyle(
            color: AppColors.thirdGoldenWheat,
            fontWeight: FontWeight.w700,
            fontSize: 13.f(context),
          ),
        ),
      ),
      body: SafeArea(
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
                              _buildHeaderCard(context)
                                  .animate()
                                  .fadeIn(duration: 350.ms)
                                  .slideY(begin: -0.1, end: 0),
                              SizedBox(height: 22.h(context)),
                              _buildFilters(context),
                              if (assignedTasks.isNotEmpty) ...[
                                SizedBox(height: 22.h(context)),
                                _buildSectionHeader(
                                  context,
                                  title: 'المهام المعيّنة',
                                  count: assignedTasks.length,
                                ),
                                SizedBox(height: 12.h(context)),
                                ...assignedTasks.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final task = entry.value;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 14.h(context),
                                    ),
                                    child: CustomDailyTaskCard(
                                      title: task.title,
                                      location:
                                          locationLabelForDelegateTask(task),
                                      distance:
                                          statusLabelForDelegateTask(task),
                                      time: timeLabelForDelegateTask(task),
                                      status: cardStatusForDelegateTask(task),
                                      startLabel: task.isInProgress
                                          ? 'متابعة المهمة'
                                          : 'بدء المهمة',
                                      onTap: () =>
                                          showDelegateAssignedTaskSheet(
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
                                      onInfo: () =>
                                          showDelegateAssignedTaskSheet(
                                        context,
                                        task,
                                      ),
                                    )
                                        .animate()
                                        .fadeIn(
                                          duration: 300.ms,
                                          delay: (40 * index).ms,
                                        )
                                        .slideY(begin: 0.08, end: 0),
                                  );
                                }),
                              ],
                              SizedBox(height: 22.h(context)),
                              _buildSectionHeader(
                                context,
                                title: ' قائمة المهام',
                                count: filteredPins.length,
                              ),
                              SizedBox(height: 12.h(context)),
                            ]),
                          ),
                        ),
                        if (isInitialLoading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryForest,
                              ),
                            ),
                          )
                        else if (filteredPins.isEmpty)
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
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
                              96.h(context),
                            ),
                            sliver: SliverList.builder(
                              itemCount: filteredPins.length,
                              itemBuilder: (context, index) {
                                final pin = filteredPins[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 14.h(context),
                                  ),
                                  child: CustomDailyTaskCard(
                                    title: pin.displayTitle,
                                    location: pin.displayLocation,
                                    distance: statusLabelForPin(pin),
                                    time:
                                        pin.status == SurveyPinStatus.completed
                                            ? 'محفوظ'
                                            : 'مفتوح',
                                    status: cardStatusForPin(pin),
                                    startLabel:
                                        pin.status == SurveyPinStatus.inProgress
                                            ? 'متابعة المهمة'
                                            : 'بدء المهمة',
                                    isSelected: pin.id == state.selectedPinId,
                                    onTap: () => _openOnMap(pin),
                                    onStart: () => resumeDelegateSurvey(
                                      context,
                                      pin,
                                    ),
                                    onNavigate: () => _openOnMap(pin),
                                    onInfo: () => showPinInfoSheet(
                                      context,
                                      pin,
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 300.ms,
                                        delay: (40 * index).ms,
                                      )
                                      .slideY(begin: 0.08, end: 0),
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

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.s(context)),
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
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.s(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r(context)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.assignment_rounded,
              color: Colors.white,
              size: 30.ic(context),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز المهام الميدانية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'تابع المسوحات والمهام المعيّنة، ونفّذها بسرعة من الخريطة أو من هذه القائمة.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.s(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(26.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          CustomTrackFilterButton(
            label: 'الكل',
            isSelected: _statusFilter == null,
            onTap: () => setState(() => _statusFilter = null),
          ),
          SizedBox(width: 6.w(context)),
          CustomTrackFilterButton(
            label: 'قيد التنفيذ',
            isSelected: _statusFilter == SurveyPinStatus.inProgress,
            onTap: () =>
                setState(() => _statusFilter = SurveyPinStatus.inProgress),
          ),
          SizedBox(width: 6.w(context)),
          CustomTrackFilterButton(
            label: 'مكتملة',
            isSelected: _statusFilter == SurveyPinStatus.completed,
            onTap: () =>
                setState(() => _statusFilter = SurveyPinStatus.completed),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 5.w(context),
          height: 20.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 5.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '$count ${count == 1 ? 'مهمة' : 'مهام'}',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryForest,
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
        ? 'ابدأ مسحاً جديداً من الخريطة عبر الزر أدناه.'
        : 'جرّب تغيير الفلتر لعرض مهام أخرى.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 40.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.s(context)),
            decoration: BoxDecoration(
              color: AppColors.thirdGoldenWheat.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.explore_outlined,
              size: 40.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
