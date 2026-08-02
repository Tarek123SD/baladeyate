import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDelegateBuildingCard extends StatelessWidget {
  const CustomDelegateBuildingCard({
    super.key,
    required this.survey,
    this.onTap,
    this.onDelete,
  });

  final BuildingSurvey survey;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get _name {
    final name = survey.building.name.trim();
    return name.isNotEmpty ? name : 'مبنى بدون اسم';
  }

  String get _metaLine {
    final parts = <String>[];
    final declared = survey.building.totalFloors.trim();
    final entered = survey.floors.length;
    if (declared.isNotEmpty) {
      parts.add('$declared طابق');
    } else if (entered > 0) {
      parts.add('$entered طابق');
    }
    parts.add('${survey.totalSavedApartments} شقة');
    final estate = survey.building.realEstateNumber.trim();
    if (estate.isNotEmpty) parts.add(estate);
    return parts.join(' · ');
  }

  String get _phaseLabel {
    return switch (survey.phase) {
      SurveyPhase.buildingPending => 'بيانات المبنى',
      SurveyPhase.floorsInProgress => 'قيد الإدخال',
      SurveyPhase.completed => 'مكتمل',
    };
  }

  Color get _phaseColor {
    return switch (survey.phase) {
      SurveyPhase.buildingPending => AppColors.primaryGoldenWheat,
      SurveyPhase.floorsInProgress => const Color(0xFFE65100),
      SurveyPhase.completed => AppColors.thirdForest,
    };
  }

  String get _actionHint {
    return survey.phase == SurveyPhase.completed ? 'مراجعة' : 'متابعة';
  }

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);

    return Material(
      color: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            12.w(context),
            10.h(context),
            8.w(context),
            10.h(context),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 4.w(context),
                height: 42.h(context),
                decoration: BoxDecoration(
                  color: _phaseColor,
                  borderRadius: BorderRadius.circular(4.r(context)),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Container(
                width: 36.s(context),
                height: 36.s(context),
                decoration: BoxDecoration(
                  color: _phaseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Icon(
                  Icons.apartment_rounded,
                  color: _phaseColor,
                  size: 18.ic(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            _name,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.primaryForest,
                              fontSize: 14.f(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (survey.buildingId != null) ...[
                          SizedBox(width: 4.w(context)),
                          Icon(
                            Icons.cloud_done_outlined,
                            size: 14.ic(context),
                            color: AppColors.thirdForest,
                          ),
                        ],
                        SizedBox(width: 6.w(context)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w(context),
                            vertical: 3.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: _phaseColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12.r(context)),
                          ),
                          child: Text(
                            _phaseLabel,
                            style: TextStyle(
                              color: _phaseColor,
                              fontSize: 10.f(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      _metaLine,
                      textDirection: TextDirection.rtl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryCharcoal
                            .withValues(alpha: 0.7),
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h(context)),
                    Text(
                      'اضغط لل$_actionHint',
                      style: TextStyle(
                        color: AppColors.primaryForest.withValues(alpha: 0.65),
                        fontSize: 10.f(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'حذف',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 18.ic(context),
                    color: AppColors.alertRed.withValues(alpha: 0.85),
                  ),
                )
              else
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
