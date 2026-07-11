import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubScreen extends StatelessWidget {
  const BuildingHubScreen({super.key, required this.pinId});

  final String pinId;

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.w(context)),
                    child: _ProgressCard(survey: survey),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الطوابق',
                          style: TextStyle(
                            fontSize: 18.s(context),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryForest,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.push(
                            '/floor',
                            extra: SurveyNavigationContext(
                              pinId: pinId,
                              isNewFloor: true,
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة طابق'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: survey.floors.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد طوابق بعد.\nاضغط "إضافة طابق" للبدء.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.s(context),
                                color: AppColors.secondaryCharcoal,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w(context)),
                            itemCount: survey.floors.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.h(context)),
                            itemBuilder: (context, index) {
                              final floor = survey.floors[index];
                              final label = floor.floorName.isNotEmpty
                                  ? floor.floorName
                                  : 'الطابق ${floor.floorNumber}';
                              return _FloorListTile(
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
                              );
                            },
                          ),
                  ),
                  if (survey.floors.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16.w(context)),
                      child: OutlinedButton(
                        onPressed: survey.phase == SurveyPhase.completed
                            ? null
                            : () async {
                                await context
                                    .read<BuildingSurveyCubit>()
                                    .markBuildingComplete();
                                if (context.mounted) context.go('/delegate/home');
                              },
                        child: const Text('إنهاء مسح المبنى'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.survey});

  final dynamic survey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.secondaryGoldenWheat.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            survey.building.name.isNotEmpty
                ? survey.building.name
                : (survey.building.realEstateNumber.isNotEmpty
                    ? 'رقم عقاري: ${survey.building.realEstateNumber}'
                    : 'مبنى غير محدد'),
            style: TextStyle(
              fontSize: 13.s(context),
              color: AppColors.secondaryCharcoal,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            '${survey.floors.length} طابق · ${survey.totalSavedApartments} شقة مسجلة',
            style: TextStyle(
              fontSize: 14.s(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloorListTile extends StatelessWidget {
  const _FloorListTile({
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
      color: Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Padding(
          padding: EdgeInsets.all(16.w(context)),
          child: Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: AppColors.primaryForest,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 16.s(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryCharcoal,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 13.s(context),
                        color: AppColors.primaryGoldenWheat,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left,
                color: AppColors.primaryForest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
