import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingsPhaseFilters extends StatelessWidget {
  const BuildingsPhaseFilters({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final SurveyPhase? selected;
  final ValueChanged<SurveyPhase?> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(SurveyPhase?, String)>[
      (null, 'الكل'),
      (SurveyPhase.floorsInProgress, 'قيد الإدخال'),
      (SurveyPhase.completed, 'مكتمل'),
      (SurveyPhase.buildingPending, 'بيانات'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          for (final option in options) ...[
            BuildingsFilterChip(
              label: option.$2,
              selected: selected == option.$1,
              onTap: () => onSelected(option.$1),
            ),
            SizedBox(width: 8.w(context)),
          ],
        ],
      ),
    );
  }
}

class BuildingsFilterChip extends StatelessWidget {
  const BuildingsFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryForest : Colors.white,
      borderRadius: BorderRadius.circular(16.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 7.h(context),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: selected
                  ? AppColors.primaryForest
                  : AppColors.primaryForest.withValues(alpha: 0.14),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.primaryForest,
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
