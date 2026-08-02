import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_delegate_building_card.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_empty_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_list_header.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_no_results_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_phase_filters.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_search_field.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/buildings_stats_header.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delete_building_confirmation_dialog.dart';
import 'package:baladeyate/features/delegate/repo/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/repo/local_survey_pin_store.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateBuildingsScreen extends StatefulWidget {
  const DelegateBuildingsScreen({super.key});

  @override
  State<DelegateBuildingsScreen> createState() =>
      _DelegateBuildingsScreenState();
}

class _DelegateBuildingsScreenState extends State<DelegateBuildingsScreen>
    with RouteAware {
  bool _routeSubscribed = false;
  bool _isLoading = true;
  List<BuildingSurvey> _surveys = const [];
  int? _lastShellIndex;
  SurveyPhase? _phaseFilter;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _query) return;
      setState(() => _query = next);
    });
    _loadBuildings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final shell = StatefulNavigationShell.maybeOf(context);
    if (shell != null) {
      final index = shell.currentIndex;
      if (index == 3 && _lastShellIndex != 3) {
        _loadBuildings();
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
    _loadBuildings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadBuildings() async {
    setState(() => _isLoading = true);
    final surveys = await sl<LocalBuildingSurveyStore>().loadAllSurveys();
    if (!mounted) return;
    setState(() {
      _surveys = surveys;
      _isLoading = false;
    });
  }

  Future<void> _openSurvey(BuildingSurvey survey) async {
    if (survey.phase == SurveyPhase.buildingPending) {
      await context.push(
        '/info',
        extra: SurveyLocation(
          pinId: survey.pinId,
          latitude: survey.latitude,
          longitude: survey.longitude,
        ),
      );
    } else {
      await context.push('/building/${survey.pinId}');
    }
    if (!mounted) return;
    await _loadBuildings();
    await sl<DailyTasksCubit>().loadPins();
  }

  Future<bool> _confirmDelete(BuildingSurvey survey) async {
    final name = survey.building.name.trim().isNotEmpty
        ? survey.building.name.trim()
        : 'مبنى بدون اسم';
    final hasServerCopy = survey.buildingId != null;

    final confirmed = await showDeleteBuildingConfirmationDialog(
      context,
      buildingName: name,
      hasServerCopy: hasServerCopy,
    );

    return confirmed == true;
  }

  Future<void> _performDelete(BuildingSurvey survey) async {
    var serverDeleted = true;
    final buildingId = survey.buildingId;
    if (buildingId != null) {
      try {
        await sl<DelegateRepository>().deleteBuilding(buildingId);
      } catch (_) {
        serverDeleted = false;
      }
    }

    await sl<LocalBuildingSurveyStore>().removeSurvey(survey.pinId);
    await sl<LocalSurveyPinStore>().removeDraftPin(survey.pinId);
    await sl<DailyTasksCubit>().loadPins();

    if (!mounted) return;
    setState(() {
      _surveys = _surveys.where((item) => item.pinId != survey.pinId).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          serverDeleted || buildingId == null
              ? 'تم حذف المبنى من القائمة'
              : 'تم حذف المبنى محلياً، وتعذّر حذفه من الخادم',
        ),
      ),
    );
  }

  Future<void> _deleteSurvey(BuildingSurvey survey) async {
    final allowed = await _confirmDelete(survey);
    if (!allowed || !mounted) return;
    await _performDelete(survey);
  }

  List<BuildingSurvey> get _visibleSurveys {
    final query = _query.toLowerCase();
    return _surveys.where((survey) {
      if (_phaseFilter != null && survey.phase != _phaseFilter) {
        return false;
      }
      if (query.isEmpty) return true;
      final name = survey.building.name.toLowerCase();
      final estate = survey.building.realEstateNumber.toLowerCase();
      return name.contains(query) || estate.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final bottomClearance =
        DelegateBottomNavigationBar.clearance(context) + 16.h(context);
    final visible = _visibleSurveys;
    final completedCount =
        _surveys.where((s) => s.phase == SurveyPhase.completed).length;
    final inProgressCount =
        _surveys.where((s) => s.phase == SurveyPhase.floorsInProgress).length;
    final pendingCount =
        _surveys.where((s) => s.phase == SurveyPhase.buildingPending).length;

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
              child: RefreshIndicator(
                color: AppColors.primaryForest,
                onRefresh: _loadBuildings,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        14.h(context),
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          BuildingsStatsHeader(
                            total: _surveys.length,
                            completed: completedCount,
                            inProgress: inProgressCount,
                            pending: pendingCount,
                          )
                              .animate()
                              .fadeIn(duration: 320.ms)
                              .slideY(begin: -0.06, end: 0),
                          SizedBox(height: 12.h(context)),
                          BuildingsSearchField(
                            controller: _searchController,
                            query: _query,
                          ),
                          SizedBox(height: 10.h(context)),
                          BuildingsPhaseFilters(
                            selected: _phaseFilter,
                            onSelected: (phase) =>
                                setState(() => _phaseFilter = phase),
                          ),
                          SizedBox(height: 12.h(context)),
                          BuildingsListHeader(count: visible.length),
                          SizedBox(height: 8.h(context)),
                        ]),
                      ),
                    ),
                    if (_isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_surveys.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          bottomClearance,
                        ),
                        sliver: const SliverToBoxAdapter(
                          child: BuildingsEmptyState(),
                        ),
                      )
                    else if (visible.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          bottomClearance,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: BuildingsNoResultsState(
                            onClearFilters: () {
                              setState(() {
                                _phaseFilter = null;
                                _searchController.clear();
                              });
                            },
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
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final survey = visible[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h(context)),
                              child: CustomDelegateBuildingCard(
                                survey: survey,
                                onTap: () => _openSurvey(survey),
                                onDelete: () => _deleteSurvey(survey),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 260.ms,
                                    delay: (30 * index).ms,
                                  )
                                  .slideY(begin: 0.04, end: 0),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
