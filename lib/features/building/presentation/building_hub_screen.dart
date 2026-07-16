import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubScreen extends StatelessWidget {
  const BuildingHubScreen({super.key, required this.pinId});

  final String pinId;

  Future<void> _finishSurvey(BuildContext context, BuildingSurvey survey) async {
    if (survey.phase == SurveyPhase.completed) return;

    await context.read<BuildingSurveyCubit>().markBuildingComplete();
    await sl<DailyTasksCubit>().refreshDashboard();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم إنهاء مسح المبنى. يمكنك مراجعته لاحقاً من قائمة المباني.',
        ),
      ),
    );
    context.go('/delegate/buildings');
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocBuilder<BuildingSurveyCubit, BuildingSurveyState>(
      builder: (context, state) {
        final survey = switch (state) {
          BuildingSurveyLoaded(:final survey) => survey,
          BuildingSurveySaving(:final survey) => survey,
          BuildingSurveyFailure(:final survey) => survey,
          _ => null,
        };

        if (survey == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isCompleted = survey.phase == SurveyPhase.completed;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(
              showBackButton: true,
              showSettings: false,
              showNotifications: false,
            ),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              8.h(context),
                              horizontalPadding,
                              0,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _HeaderCard(survey: survey)
                                    .animate()
                                    .fadeIn(duration: 350.ms)
                                    .slideY(begin: -0.08, end: 0),
                                SizedBox(height: 20.h(context)),
                                _SectionHeader(
                                  title: 'الطوابق',
                                  count: survey.floors.length,
                                  action: TextButton.icon(
                                    onPressed: () => context.push(
                                      '/floor',
                                      extra: SurveyNavigationContext(
                                        pinId: pinId,
                                        isNewFloor: true,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.green,
                                    ),
                                    icon: Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 20.ic(context),
                                    ),
                                    label: Text(
                                      'إضافة طابق',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.f(context),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h(context)),
                              ]),
                            ),
                          ),
                          if (survey.floors.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                child: _EmptyFloorsState(
                                  onAddFloor: () => context.push(
                                    '/floor',
                                    extra: SurveyNavigationContext(
                                      pinId: pinId,
                                      isNewFloor: true,
                                    ),
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
                                16.h(context),
                              ),
                              sliver: SliverList.separated(
                                itemCount: survey.floors.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 12.h(context)),
                                itemBuilder: (context, index) {
                                  final floor = survey.floors[index];
                                  final label = floor.floorName.isNotEmpty
                                      ? floor.floorName
                                      : 'الطابق ${floor.floorNumber}';
                                  return _FloorCard(
                                    title: label,
                                    subtitle:
                                        '${floor.savedApartmentCount} شقة مسجلة'
                                        '${floor.expectedApartmentCount.isNotEmpty ? ' / ${floor.expectedApartmentCount} متوقعة' : ''}',
                                    onTap: () => context.push(
                                      '/building/$pinId/floor/${floor.localId}',
                                    ),
                                    onEdit: () => context.push(
                                      '/floor',
                                      extra: SurveyNavigationContext(
                                        pinId: pinId,
                                        floorLocalId: floor.localId,
                                      ),
                                    ),
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 300.ms,
                                        delay: (40 * index).ms,
                                      )
                                      .slideY(begin: 0.06, end: 0);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (survey.floors.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          8.h(context),
                          horizontalPadding,
                          16.h(context),
                        ),
                        child: SizedBox(
                          height: 52.h(context),
                          width: double.infinity,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isCompleted
                                  ? null
                                  : () => _finishSurvey(context, survey),
                              borderRadius:
                                  BorderRadius.circular(16.r(context)),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: isCompleted
                                      ? null
                                      : const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            AppColors.primaryForest,
                                            AppColors.secondaryForest,
                                            AppColors.thirdForest,
                                          ],
                                        ),
                                  color: isCompleted
                                      ? AppColors.secondaryCharcoal
                                          .withValues(alpha: 0.12)
                                      : null,
                                  borderRadius:
                                      BorderRadius.circular(16.r(context)),
                                  boxShadow: isCompleted
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.primaryForest
                                                .withValues(alpha: 0.28),
                                            blurRadius: 16,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCompleted
                                            ? Icons.check_circle_rounded
                                            : Icons.flag_rounded,
                                        color: isCompleted
                                            ? AppColors.secondaryCharcoal
                                                .withValues(alpha: 0.55)
                                            : AppColors.thirdGoldenWheat,
                                        size: 20.ic(context),
                                      ),
                                      SizedBox(width: 8.w(context)),
                                      Text(
                                        isCompleted
                                            ? 'تم إنهاء المسح'
                                            : 'إنهاء مسح المبنى',
                                        style: TextStyle(
                                          color: isCompleted
                                              ? AppColors.secondaryCharcoal
                                                  .withValues(alpha: 0.55)
                                              : AppColors.thirdGoldenWheat,
                                          fontSize: 15.f(context),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.survey});

  final BuildingSurvey survey;

  String get _title {
    if (survey.building.name.trim().isNotEmpty) {
      return survey.building.name.trim();
    }
    if (survey.building.realEstateNumber.trim().isNotEmpty) {
      return 'رقم عقاري: ${survey.building.realEstateNumber}';
    }
    return 'مبنى قيد المسح';
  }

  String? get _address {
    final estate = survey.building.realEstateNumber.trim();
    if (estate.isNotEmpty && survey.building.name.trim().isNotEmpty) {
      return estate;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = survey.phase == SurveyPhase.completed;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  size: 28.ic(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.f(context),
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    if (_address != null) ...[
                      SizedBox(height: 4.h(context)),
                      Text(
                        _address!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12.f(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 6.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Text(
                  isCompleted ? 'مكتمل' : 'قيد الإدخال',
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h(context)),
          Text(
            'أضف الطوابق والشقق لإكمال مسح المبنى، ثم أنهِ المسح عند الانتهاء.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.f(context),
              height: 1.55,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  icon: Icons.layers_outlined,
                  label: 'الطوابق',
                  value: '${survey.floors.length}',
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: _StatPill(
                  icon: Icons.meeting_room_outlined,
                  label: 'الشقق',
                  value: '${survey.totalSavedApartments}',
                ),
              ),
              if (survey.building.totalFloors.trim().isNotEmpty) ...[
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: _StatPill(
                    icon: Icons.tag_outlined,
                    label: 'المخطط',
                    value: survey.building.totalFloors.trim(),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 10.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.thirdGoldenWheat, size: 18.ic(context)),
          SizedBox(height: 6.h(context)),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 2.h(context)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.f(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.action,
  });

  final String title;
  final int count;
  final Widget action;

  @override
  Widget build(BuildContext context) {
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
        SizedBox(width: 8.w(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
              color: AppColors.primaryForest,
            ),
          ),
        ),
        const Spacer(),
        action,
      ],
    );
  }
}

class _EmptyFloorsState extends StatelessWidget {
  const _EmptyFloorsState({required this.onAddFloor});

  final VoidCallback onAddFloor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 36.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
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
              Icons.layers_outlined,
              size: 40.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد طوابق بعد',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'ابدأ بإضافة أول طابق لتسجيل الشقق وبيانات الأسر.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ),
          SizedBox(height: 18.h(context)),
          SizedBox(
            height: 46.h(context),
            child: ElevatedButton.icon(
              onPressed: onAddFloor,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.thirdGoldenWheat,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'إضافة طابق',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.f(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorCard extends StatelessWidget {
  const _FloorCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onEdit,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r(context)),
        child: Ink(
          padding: EdgeInsets.all(16.s(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.08),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.s(context)),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14.r(context)),
                ),
                child: Icon(
                  Icons.layers_rounded,
                  color: AppColors.primaryForest,
                  size: 22.ic(context),
                ),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.f(context),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.f(context),
                        color: AppColors.secondaryCharcoal
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: AppColors.primaryForest.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r(context)),
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(12.r(context)),
                  child: SizedBox(
                    width: 40.w(context),
                    height: 40.h(context),
                    child: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryForest,
                      size: 18.ic(context),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 6.w(context)),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primaryForest.withValues(alpha: 0.7),
                size: 22.ic(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
