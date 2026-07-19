import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_delegate_building_card.dart';
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

  @override
  void initState() {
    super.initState();
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
                            Icons.apartment_rounded,
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

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                        16.h(context),
                        horizontalPadding,
                        0,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(context)
                              .animate()
                              .fadeIn(duration: 350.ms)
                              .slideY(begin: -0.08, end: 0),
                          SizedBox(height: 20.h(context)),
                          _buildListHeader(context),
                          SizedBox(height: 12.h(context)),
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
                          24.h(context),
                        ),
                        sliver: SliverList.builder(
                          itemCount: _surveys.length,
                          itemBuilder: (context, index) {
                            final survey = _surveys[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h(context)),
                              child: CustomDelegateBuildingCard(
                                survey: survey,
                                onTap: () => _openSurvey(survey),
                                onEdit: () => _openSurvey(survey),
                                onDelete: () => _deleteSurvey(survey),
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              Icons.apartment_rounded,
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
                  'المباني المُدخلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'راجع وعدّل المباني والطوابق والشقق التي أدخلتها أثناء المسوحات الميدانية.',
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

  Widget _buildListHeader(BuildContext context) {
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
          'قائمة المباني',
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
            '${_surveys.length} مبنى',
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
              Icons.domain_disabled_outlined,
              size: 40.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد مباني مُدخلة بعد',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'ابدأ مسحاً جديداً من الخريطة، ثم احفظ بيانات المبنى لتظهر هنا للمراجعة والتعديل.',
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
