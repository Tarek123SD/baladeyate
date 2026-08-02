import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorHubApartmentCard extends StatelessWidget {
  const FloorHubApartmentCard({
    super.key,
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
