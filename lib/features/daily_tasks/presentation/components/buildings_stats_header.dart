import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingsStatsHeader extends StatelessWidget {
  const BuildingsStatsHeader({
    super.key,
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.pending,
  });

  final int total;
  final int completed;
  final int inProgress;
  final int pending;

  @override
  Widget build(BuildContext context) {
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
              Icon(
                AppIcons.buildings,
                color: Colors.white,
                size: 20.ic(context),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: Text(
                  'المباني المُدخلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.f(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              BuildingsStatPill(label: 'مكتمل', value: '$completed'),
              SizedBox(width: 8.w(context)),
              BuildingsStatPill(label: 'قيد الإدخال', value: '$inProgress'),
              SizedBox(width: 8.w(context)),
              BuildingsStatPill(label: 'بيانات', value: '$pending'),
            ],
          ),
        ],
      ),
    );
  }
}

class BuildingsStatPill extends StatelessWidget {
  const BuildingsStatPill({
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
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12.r(context)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 10.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
