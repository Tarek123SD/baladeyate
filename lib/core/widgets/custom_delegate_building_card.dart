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
    this.onEdit,
    this.onDelete,
  });

  final BuildingSurvey survey;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String get _name {
    final name = survey.building.name.trim();
    return name.isNotEmpty ? name : 'مبنى بدون اسم';
  }

  String get _floorsLabel {
    final declared = survey.building.totalFloors.trim();
    final entered = survey.floors.length;
    if (declared.isNotEmpty) {
      return entered > 0 ? '$declared طابق · $entered مُدخل' : '$declared طابق';
    }
    if (entered > 0) return '$entered طابق';
    return 'لم تُحدد الطوابق';
  }

  String? get _address {
    final estate = survey.building.realEstateNumber.trim();
    if (estate.isNotEmpty) return estate;
    return null;
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
      SurveyPhase.floorsInProgress => AppColors.thirdForest,
      SurveyPhase.completed => AppColors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? onEdit,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.s(context)),
                    decoration: BoxDecoration(
                      color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14.r(context)),
                    ),
                    child: Icon(
                      Icons.apartment_rounded,
                      color: AppColors.primaryForest,
                      size: 24.ic(context),
                    ),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 15.f(context),
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 6.h(context)),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 15.ic(context),
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.65),
                            ),
                            SizedBox(width: 4.w(context)),
                            Flexible(
                              child: Text(
                                _floorsLabel,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: 0.8),
                                  fontSize: 13.f(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_address != null) ...[
                          SizedBox(height: 4.h(context)),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 15.ic(context),
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.65),
                              ),
                              SizedBox(width: 4.w(context)),
                              Flexible(
                                child: Text(
                                  _address!,
                                  textDirection: TextDirection.rtl,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.secondaryCharcoal
                                        .withValues(alpha: 0.75),
                                    fontSize: 12.f(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w(context),
                      vertical: 5.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: _phaseColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r(context)),
                    ),
                    child: Text(
                      _phaseLabel,
                      style: TextStyle(
                        color: _phaseColor,
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h(context)),
              Wrap(
                textDirection: TextDirection.rtl,
                spacing: 8.w(context),
                runSpacing: 8.h(context),
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _MetaChip(
                    icon: Icons.meeting_room_outlined,
                    label: '${survey.totalSavedApartments} شقة',
                  ),
                  if (survey.buildingId != null)
                    const _MetaChip(
                      icon: Icons.cloud_done_outlined,
                      label: 'محفوظ على الخادم',
                    ),
                ],
              ),
              SizedBox(height: 12.h(context)),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42.h(context),
                      child: OutlinedButton.icon(
                        onPressed: onEdit ?? onTap,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryForest,
                          side: BorderSide(
                            color: AppColors.primaryForest
                                .withValues(alpha: 0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r(context)),
                          ),
                        ),
                        icon: Icon(Icons.edit_outlined, size: 16.ic(context)),
                        label: Text(
                          survey.phase == SurveyPhase.completed
                              ? 'مراجعة'
                              : 'تعديل',
                          style: TextStyle(
                            fontSize: 13.f(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    SizedBox(width: 8.w(context)),
                    Material(
                      color: AppColors.alertRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r(context)),
                      child: InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(12.r(context)),
                        child: SizedBox(
                          width: 42.w(context),
                          height: 42.h(context),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 20.ic(context),
                            color: AppColors.alertRed,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w(context),
        vertical: 4.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10.r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.ic(context), color: AppColors.primaryForest),
          SizedBox(width: 4.w(context)),
          Text(
            label,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 11.f(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
