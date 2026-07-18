import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
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

  Future<void> _openAddApartment(BuildContext context) async {
    await context.read<BuildingSurveyCubit>().startNewApartment(floorLocalId);
    if (!context.mounted) return;
    await context.push(
      '/apartment',
      extra: SurveyNavigationContext(
        pinId: pinId,
        floorLocalId: floorLocalId,
      ),
    );
  }

  Future<void> _openEditApartment(
    BuildContext context,
    String apartmentLocalId,
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
      ),
    );
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
                            floor: floor,
                          )
                              .animate()
                              .fadeIn(duration: 350.ms)
                              .slideY(begin: -0.08, end: 0),
                          SizedBox(height: 20.h(context)),
                          _SectionHeader(
                            title: 'الشقق',
                            count: floor.apartments.length,
                            action: TextButton.icon(
                              onPressed: () => _openAddApartment(context),
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
                          child: _EmptyApartmentsState(
                            onAddApartment: () => _openAddApartment(context),
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
                            return _ApartmentCard(
                              index: index + 1,
                              unit: apt,
                              onTap: () => _openEditApartment(
                                context,
                                apt.localId,
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
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.survey,
    required this.floor,
  });

  final BuildingSurvey survey;
  final FloorDraft floor;

  String get _floorTitle {
    if (floor.floorName.trim().isNotEmpty) return floor.floorName.trim();
    if (floor.floorNumber.trim().isNotEmpty) {
      return 'الطابق ${floor.floorNumber}';
    }
    return 'طابق';
  }

  String get _buildingTitle {
    final name = survey.building.name.trim();
    if (name.isNotEmpty) return name;
    if (survey.building.realEstateNumber.trim().isNotEmpty) {
      return 'رقم عقاري: ${survey.building.realEstateNumber}';
    }
    return 'المبنى';
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.layers_rounded,
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
                      _floorTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.f(context),
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      _buildingTitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.f(context),
                      ),
                    ),
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
                  '${floor.savedApartmentCount} شقة',
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
            'سجّل الشقق وبيانات الأسر على هذا الطابق، ثم راجعها أو عدّلها في أي وقت.',
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
                  icon: Icons.meeting_room_outlined,
                  label: 'مسجلة',
                  value: '${floor.savedApartmentCount}',
                ),
              ),
              if (floor.expectedApartmentCount.trim().isNotEmpty) ...[
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: _StatPill(
                    icon: Icons.tag_outlined,
                    label: 'متوقعة',
                    value: floor.expectedApartmentCount.trim(),
                  ),
                ),
              ],
              if (floor.floorPlanNumber.trim().isNotEmpty) ...[
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: _StatPill(
                    icon: Icons.map_outlined,
                    label: 'المخطط',
                    value: floor.floorPlanNumber.trim(),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _EmptyApartmentsState extends StatelessWidget {
  const _EmptyApartmentsState({required this.onAddApartment});

  final VoidCallback onAddApartment;

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
              Icons.meeting_room_outlined,
              size: 40.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد شقق مسجلة',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'ابدأ بإضافة أول شقة على هذا الطابق لتسجيل بيانات السكن والأسرة.',
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
              onPressed: onAddApartment,
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
                'إضافة شقة',
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

class _ApartmentCard extends StatelessWidget {
  const _ApartmentCard({
    required this.index,
    required this.unit,
    required this.onTap,
  });

  final int index;
  final ApartmentUnitDraft unit;
  final VoidCallback onTap;

  String get _subtitle {
    if (unit.familyBook.trim().isNotEmpty) {
      return 'دفتر عائلة: ${unit.familyBook.trim()}';
    }
    if (unit.isSaved) return 'مسجلة · اضغط للمراجعة';
    return 'قيد الإدخال';
  }

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
                  Icons.door_front_door_rounded,
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
                      'شقة $index',
                      style: TextStyle(
                        fontSize: 15.f(context),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 12.f(context),
                        color:
                            AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 5.h(context),
                ),
                decoration: BoxDecoration(
                  color: unit.isSaved
                      ? AppColors.green.withValues(alpha: 0.12)
                      : AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      unit.isSaved
                          ? Icons.check_circle_rounded
                          : Icons.pending_outlined,
                      size: 14.ic(context),
                      color: unit.isSaved
                          ? AppColors.green
                          : AppColors.primaryGoldenWheat,
                    ),
                    SizedBox(width: 4.w(context)),
                    Text(
                      unit.isSaved ? 'محفوظة' : 'مسودة',
                      style: TextStyle(
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.w700,
                        color: unit.isSaved
                            ? AppColors.green
                            : AppColors.primaryForest,
                      ),
                    ),
                  ],
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
