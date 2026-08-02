import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubHeaderCard extends StatelessWidget {
  const BuildingHubHeaderCard({
    super.key,
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
              BuildingHubMiniStat(
                label: 'طوابق',
                value: '${survey.floors.length}',
              ),
              SizedBox(width: 8.w(context)),
              BuildingHubMiniStat(
                label: 'شقق',
                value: expectedApartments > 0
                    ? '$savedApartments/$expectedApartments'
                    : '$savedApartments',
              ),
              if (survey.building.totalFloors.trim().isNotEmpty) ...[
                SizedBox(width: 8.w(context)),
                BuildingHubMiniStat(
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

class BuildingHubMiniStat extends StatelessWidget {
  const BuildingHubMiniStat({
    super.key,
    required this.label,
    required this.value,
  });

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
