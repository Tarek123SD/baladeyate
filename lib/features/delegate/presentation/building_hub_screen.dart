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
import 'package:baladeyate/features/delegate/presentation/components/building_hub_completed_banner.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_hub_empty_floors_state.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_hub_floor_card.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_hub_header_card.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_hub_section_header.dart';
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
                      child: RefreshIndicator(
                        color: AppColors.primaryForest,
                        onRefresh: () => context
                            .read<BuildingSurveyCubit>()
                            .loadSurvey(pinId),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
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
                                BuildingHubHeaderCard(
                                  survey: survey,
                                  apartmentProgress: apartmentProgress,
                                  savedApartments: savedTotal,
                                  expectedApartments: expectedTotal,
                                )
                                    .animate()
                                    .fadeIn(duration: 320.ms)
                                    .slideY(begin: -0.06, end: 0),
                                SizedBox(height: 14.h(context)),
                                BuildingHubSectionHeader(
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
                                child: BuildingHubEmptyFloorsState(
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
                                  return BuildingHubFloorCard(
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
                            ? const BuildingHubCompletedBanner()
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
