import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_hub_apartment_card.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_hub_empty_apartments_state.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_hub_header_card.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_hub_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorHubScreen extends StatelessWidget {
  const FloorHubScreen({
    super.key,
    required this.pinId,
    required this.floorLocalId,
  });

  final String pinId;
  final String floorLocalId;

  Future<void> _openAddApartment(BuildContext context, int apartmentsCount) async {
    await context.read<BuildingSurveyCubit>().startNewApartment(floorLocalId);
    if (!context.mounted) return;
    await context.push(
      '/apartment',
      extra: SurveyNavigationContext(
        pinId: pinId,
        floorLocalId: floorLocalId,
        apartmentsCount: apartmentsCount,
      ),
    );
    if (!context.mounted) return;
    context.read<BuildingSurveyCubit>().loadSurvey(pinId);
  }

  Future<void> _openEditApartment(
    BuildContext context,
    String apartmentLocalId,
    int apartmentsCount,
  ) async {
    await context.read<BuildingSurveyCubit>().editApartmentUnit(
          floorLocalId: floorLocalId,
          apartmentLocalId: apartmentLocalId,
        );
    if (!context.mounted) return;
    await context.push(
      '/apartment',
      extra: SurveyNavigationContext(
        pinId: pinId,
        floorLocalId: floorLocalId,
        apartmentsCount: apartmentsCount,
      ),
    );
    if (!context.mounted) return;
    context.read<BuildingSurveyCubit>().loadSurvey(pinId);
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

        final floor = survey?.floorByLocalId(floorLocalId);

        if (survey == null || floor == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                child: RefreshIndicator(
                  color: AppColors.primaryForest,
                  onRefresh: () =>
                      context.read<BuildingSurveyCubit>().loadSurvey(pinId),
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
                            FloorHubHeaderCard(
                              survey: survey,
                              floor: floor,
                            )
                                .animate()
                                .fadeIn(duration: 350.ms)
                                .slideY(begin: -0.08, end: 0),
                            SizedBox(height: 20.h(context)),
                            FloorHubSectionHeader(
                              title: 'الشقق',
                              count: floor.apartments.length,
                              action: TextButton.icon(
                                onPressed: () => _openAddApartment(
                                  context,
                                  int.tryParse(floor.expectedApartmentCount) ??
                                      0,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.green,
                                ),
                                icon: Icon(
                                  Icons.add_circle_outline_rounded,
                                  size: 20.ic(context),
                                ),
                                label: Text(
                                  'إضافة شقة',
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
                      if (floor.apartments.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                            ),
                            child: FloorHubEmptyApartmentsState(
                              onAddApartment: () => _openAddApartment(
                                context,
                                int.tryParse(floor.expectedApartmentCount) ??
                                    0,
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
                          sliver: SliverList.separated(
                            itemCount: floor.apartments.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.h(context)),
                            itemBuilder: (context, index) {
                              final apt = floor.apartments[index];
                              return FloorHubApartmentCard(
                                index: index + 1,
                                unit: apt,
                                onTap: () => _openEditApartment(
                                  context,
                                  apt.localId,
                                  int.tryParse(floor.expectedApartmentCount) ??
                                      0,
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
              ),
            ),
          ),
        );
      },
    );
  }
}
