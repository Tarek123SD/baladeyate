import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:flutter/material.dart';
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

        final floor = survey?.floorByLocalId(floorLocalId);

        if (survey == null || floor == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final floorTitle = floor.floorName.isNotEmpty
            ? floor.floorName
            : 'الطابق ${floor.floorNumber}';

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
                    child: Text(
                      '$floorTitle · المبنى: ${survey.building.name}',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 14.s(context),
                        color: AppColors.secondaryCharcoal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الشقق',
                          style: TextStyle(
                            fontSize: 18.s(context),
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryForest,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            await context
                                .read<BuildingSurveyCubit>()
                                .startNewApartment(floorLocalId);
                            if (context.mounted) {
                              await context.push(
                                '/apartment',
                                extra: SurveyNavigationContext(
                                  pinId: pinId,
                                  floorLocalId: floorLocalId,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة شقة'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: floor.apartments.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد شقق مسجلة على هذا الطابق.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.s(context),
                                color: AppColors.secondaryCharcoal,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(16.w(context)),
                            itemCount: floor.apartments.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 12.h(context)),
                            itemBuilder: (context, index) {
                              final apt = floor.apartments[index];
                              return Container(
                                padding: EdgeInsets.all(16.w(context)),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  borderRadius:
                                      BorderRadius.circular(16.r(context)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      apt.isSaved
                                          ? Icons.check_circle
                                          : Icons.pending_outlined,
                                      color: AppColors.primaryForest,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'شقة ${index + 1}',
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 16.s(context),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          apt.familyBook.isNotEmpty
                                              ? 'دفتر عائلة: ${apt.familyBook}'
                                              : (apt.isSaved
                                                  ? 'مسجلة'
                                                  : 'قيد الإدخال'),
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 13.s(context),
                                            color: AppColors.primaryGoldenWheat,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
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
