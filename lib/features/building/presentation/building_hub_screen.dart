import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
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

  Future<void> _addFloor(BuildContext context) async {
    await context.push(
      '/floor',
      extra: SurveyNavigationContext(
        pinId: pinId,
        isNewFloor: true,
      ),
    );
    if (!context.mounted) return;
    context.read<BuildingSurveyCubit>().loadSurvey(pinId);
  }

  static String floorTitle(FloorDraft floor) {
    final name = floor.floorName.trim();
    final number = floor.floorNumber.trim();
    final candidate = name.isNotEmpty ? name : number;
    if (candidate.isEmpty) return 'طابق بدون رقم';
    if (RegExp(r'^\d+$').hasMatch(candidate)) {
      return 'الطابق $candidate';
    }
    return candidate;
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
        final expectedTotal = survey.floors.fold<int>(0, (sum, floor) {
          return sum + (int.tryParse(floor.expectedApartmentCount) ?? 0);
        });
        final savedTotal = survey.totalSavedApartments;
        final apartmentProgress = expectedTotal > 0
            ? (savedTotal / expectedTotal).clamp(0.0, 1.0)
            : (savedTotal > 0 ? 1.0 : 0.0);

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
            floatingActionButton: isCompleted
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _addFloor(context),
                    backgroundColor: AppColors.primaryForest,
                    icon: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 20.ic(context),
                    ),
                    label: Text(
                      'إضافة طابق',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.f(context),
                      ),
                    ),
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
                                _HeaderCard(
                                  survey: survey,
                                  apartmentProgress: apartmentProgress,
                                  savedApartments: savedTotal,
                                  expectedApartments: expectedTotal,
                                )
                                    .animate()
                                    .fadeIn(duration: 320.ms)
                                    .slideY(begin: -0.06, end: 0),
                                SizedBox(height: 14.h(context)),
                                _SectionHeader(
                                  title: 'الطوابق',
                                  count: survey.floors.length,
                                ),
                                SizedBox(height: 8.h(context)),
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
                                  onAddFloor: () => _addFloor(context),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                0,
                                horizontalPadding,
                                88.h(context),
                              ),
                              sliver: SliverList.separated(
                                itemCount: survey.floors.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 8.h(context)),
                                itemBuilder: (context, index) {
                                  final floor = survey.floors[index];
                                  final expected =
                                      int.tryParse(floor.expectedApartmentCount) ??
                                          0;
                                  final saved = floor.savedApartmentCount;
                                  return _FloorCard(
                                    title: floorTitle(floor),
                                    saved: saved,
                                    expected: expected,
                                    onTap: () async {
                                      await context.push(
                                        '/building/$pinId/floor/${floor.localId}',
                                      );
                                      if (!context.mounted) return;
                                      context
                                          .read<BuildingSurveyCubit>()
                                          .loadSurvey(pinId);
                                    },
                                    onEdit: () async {
                                      await context.push(
                                        '/floor',
                                        extra: SurveyNavigationContext(
                                          pinId: pinId,
                                          floorLocalId: floor.localId,
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      context
                                          .read<BuildingSurveyCubit>()
                                          .loadSurvey(pinId);
                                    },
                                  )
                                      .animate()
                                      .fadeIn(
                                        duration: 260.ms,
                                        delay: (30 * index).ms,
                                      )
                                      .slideY(begin: 0.04, end: 0);
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
                        child: isCompleted
                            ? _CompletedBanner()
                            : SizedBox(
                                height: 48.h(context),
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      _finishSurvey(context, survey),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primaryForest,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14.r(context)),
                                    ),
                                  ),
                                  icon: Icon(
                                    AppIcons.flag,
                                    size: 18.ic(context),
                                  ),
                                  label: Text(
                                    'إنهاء مسح المبنى',
                                    style: TextStyle(
                                      fontSize: 14.f(context),
                                      fontWeight: FontWeight.w800,
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
  const _HeaderCard({
    required this.survey,
    required this.apartmentProgress,
    required this.savedApartments,
    required this.expectedApartments,
  });

  final BuildingSurvey survey;
  final double apartmentProgress;
  final int savedApartments;
  final int expectedApartments;

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
              Container(
                width: 36.s(context),
                height: 36.s(context),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Icon(
                  AppIcons.buildings,
                  color: Colors.white,
                  size: 20.ic(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.f(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (_address != null)
                      Text(
                        _address!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11.f(context),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
                child: Text(
                  isCompleted ? 'مكتمل' : 'قيد الإدخال',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (!isCompleted) ...[
            SizedBox(height: 10.h(context)),
            Text(
              'أضف الطوابق والشقق ثم أنهِ المسح عند الانتهاء.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11.f(context),
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 12.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              _MiniStat(
                label: 'طوابق',
                value: '${survey.floors.length}',
              ),
              SizedBox(width: 8.w(context)),
              _MiniStat(
                label: 'شقق',
                value: expectedApartments > 0
                    ? '$savedApartments/$expectedApartments'
                    : '$savedApartments',
              ),
              if (survey.building.totalFloors.trim().isNotEmpty) ...[
                SizedBox(width: 8.w(context)),
                _MiniStat(
                  label: 'مخطط',
                  value: survey.building.totalFloors.trim(),
                ),
              ],
            ],
          ),
          if (expectedApartments > 0) ...[
            SizedBox(height: 10.h(context)),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r(context)),
              child: LinearProgressIndicator(
                value: apartmentProgress,
                minHeight: 6.h(context),
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                color: AppColors.thirdGoldenWheat,
              ),
            ),
            SizedBox(height: 4.h(context)),
            Text(
              'تقدم الشقق ${(apartmentProgress * 100).round()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h(context)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10.r(context)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.f(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
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
          title,
          style: TextStyle(
            fontSize: 14.f(context),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryForest,
          ),
        ),
        SizedBox(width: 8.w(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w(context),
            vertical: 3.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Text(
            '$count',
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
}

class _EmptyFloorsState extends StatelessWidget {
  const _EmptyFloorsState({required this.onAddFloor});

  final VoidCallback onAddFloor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 28.h(context),
        horizontal: 16.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(
            AppIcons.layers,
            size: 34.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 10.h(context)),
          Text(
            'لا توجد طوابق بعد',
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'أضف أول طابق لتسجيل الشقق.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
            ),
          ),
          SizedBox(height: 12.h(context)),
          FilledButton.icon(
            onPressed: onAddFloor,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة طابق'),
          ),
        ],
      ),
    );
  }
}

class _FloorCard extends StatelessWidget {
  const _FloorCard({
    required this.title,
    required this.saved,
    required this.expected,
    required this.onTap,
    required this.onEdit,
  });

  final String title;
  final int saved;
  final int expected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final progress = expected > 0
        ? (saved / expected).clamp(0.0, 1.0)
        : (saved > 0 ? 1.0 : 0.0);
    final subtitle = expected > 0 ? '$saved / $expected شقة' : '$saved شقة';

    return Material(
      color: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r(context)),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            12.w(context),
            10.h(context),
            8.w(context),
            10.h(context),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r(context)),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 34.s(context),
                height: 34.s(context),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Icon(
                  AppIcons.layers,
                  color: AppColors.primaryForest,
                  size: 18.ic(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        color: AppColors.secondaryCharcoal
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (expected > 0) ...[
                      SizedBox(height: 6.h(context)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r(context)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4.h(context),
                          backgroundColor:
                              AppColors.primaryForest.withValues(alpha: 0.08),
                          color: progress >= 1
                              ? AppColors.thirdForest
                              : AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'تعديل',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  AppIcons.edit,
                  color: AppColors.primaryForest,
                  size: 18.ic(context),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primaryForest.withValues(alpha: 0.45),
                size: 20.ic(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14.w(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.thirdForest.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(
          color: AppColors.thirdForest.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            AppIcons.statsDone,
            color: AppColors.thirdForest,
            size: 20.ic(context),
          ),
          SizedBox(width: 8.w(context)),
          Text(
            'المسح مكتمل',
            style: TextStyle(
              color: AppColors.thirdForest,
              fontSize: 14.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
