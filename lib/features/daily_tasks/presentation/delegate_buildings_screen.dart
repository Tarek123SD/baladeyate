import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_delegate_building_card.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/data/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/data/local_survey_pin_store.dart';
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

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.primaryForest.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 28.w(context)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r(context)),
                border: Border.all(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.9),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryForest.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      20.w(context),
                      20.h(context),
                      20.w(context),
                      18.h(context),
                    ),
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24.r(context)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.s(context)),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14.r(context)),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(
                            AppIcons.buildings,
                            color: AppColors.thirdGoldenWheat,
                            size: 24.ic(context),
                          ),
                        ),
                        SizedBox(width: 12.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تأكيد الحذف',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.f(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4.h(context)),
                              Text(
                                'إزالة المبنى من قائمة المسوحات',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12.f(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20.w(context),
                      18.h(context),
                      20.w(context),
                      20.h(context),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.s(context)),
                          decoration: BoxDecoration(
                            color: AppColors.thirdGoldenWheat
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(16.r(context)),
                            border: Border.all(
                              color: AppColors.primaryForest
                                  .withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.primaryForest,
                                  fontSize: 15.f(context),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 8.h(context)),
                              Text(
                                hasServerCopy
                                    ? 'سيتم حذف المبنى من قائمتك ومحاولة إزالته من الخادم أيضاً.'
                                    : 'سيتم حذف المبنى وبيانات المسح المرتبطة به من قائمتك.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: 0.75),
                                  fontSize: 13.f(context),
                                  height: 1.55,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          'لا يمكن التراجع عن هذا الإجراء.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryGoldenWheat,
                            fontSize: 12.f(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46.h(context),
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryForest,
                                    backgroundColor: AppColors.thirdGoldenWheat
                                        .withValues(alpha: 0.35),
                                    side: BorderSide(
                                      color: AppColors.primaryForest
                                          .withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14.r(context)),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.f(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w(context)),
                            Expanded(
                              child: SizedBox(
                                height: 46.h(context),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    borderRadius:
                                        BorderRadius.circular(14.r(context)),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            AppColors.thirdDeepUmber,
                                            AppColors.alertRed,
                                            Color(0xFF8B3A2F),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            14.r(context)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.alertRed
                                                .withValues(alpha: 0.28),
                                            blurRadius: 12,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'حذف',
                                          style: TextStyle(
                                            color: AppColors.thirdGoldenWheat,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14.f(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
                          _buildStatsHeader(
                            context,
                            total: _surveys.length,
                            completed: completedCount,
                            inProgress: inProgressCount,
                            pending: pendingCount,
                          )
                              .animate()
                              .fadeIn(duration: 320.ms)
                              .slideY(begin: -0.06, end: 0),
                          SizedBox(height: 12.h(context)),
                          _buildSearchField(context),
                          SizedBox(height: 10.h(context)),
                          _buildFilters(context),
                          SizedBox(height: 12.h(context)),
                          _buildListHeader(context, visible.length),
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
                        sliver: SliverToBoxAdapter(
                          child: _buildEmptyState(context),
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
                          child: _buildNoResultsState(context),
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

  Widget _buildStatsHeader(
    BuildContext context, {
    required int total,
    required int completed,
    required int inProgress,
    required int pending,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.s(context)),
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
        borderRadius: BorderRadius.circular(18.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                AppIcons.buildings,
                color: Colors.white,
                size: 20.ic(context),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: Text(
                  'المباني المُدخلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.f(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _StatPill(label: 'مكتمل', value: '$completed'),
              SizedBox(width: 8.w(context)),
              _StatPill(label: 'قيد الإدخال', value: '$inProgress'),
              SizedBox(width: 8.w(context)),
              _StatPill(label: 'بيانات', value: '$pending'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: AppColors.primaryForest,
        fontSize: 13.f(context),
      ),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو رقم العقار',
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(
          AppIcons.search,
          color: AppColors.primaryForest.withValues(alpha: 0.55),
        ),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 10.h(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: BorderSide(
            color: AppColors.primaryForest.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: BorderSide(
            color: AppColors.primaryForest.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: const BorderSide(color: AppColors.primaryForest),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final options = <(SurveyPhase?, String)>[
      (null, 'الكل'),
      (SurveyPhase.floorsInProgress, 'قيد الإدخال'),
      (SurveyPhase.completed, 'مكتمل'),
      (SurveyPhase.buildingPending, 'بيانات'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (final option in options) ...[
            _FilterChip(
              label: option.$2,
              selected: _phaseFilter == option.$1,
              onTap: () => setState(() => _phaseFilter = option.$1),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 4.w(context),
          height: 16.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة المباني',
          style: TextStyle(
            fontSize: 14.f(context),
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
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Text(
            '$count مبنى',
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryForest,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            AppIcons.buildings,
            size: 36.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 12.h(context)),
          Text(
            'لا توجد مباني مُدخلة بعد',
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'ابدأ مسحاً جديداً من تبويب الخريطة لتظهر هنا.',
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

  Widget _buildNoResultsState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 28.h(context),
        horizontal: 16.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16.r(context)),
      ),
      child: Column(
        children: [
          Text(
            'لا نتائج مطابقة',
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w800,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          TextButton(
            onPressed: () {
              setState(() {
                _phaseFilter = null;
                _searchController.clear();
              });
            },
            child: Text(
              'مسح الفلاتر',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.w700,
              ),
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
      borderRadius: BorderRadius.circular(16.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 7.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.primaryForest.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryForest,
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
