import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/admin/models/grave.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class GraveCard extends StatelessWidget {
  const GraveCard({super.key, required this.grave});

  final Grave grave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            grave.displayTitle,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 15.f(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'الحالة: ${grave.displayStatus}',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              fontSize: 13.f(context),
            ),
          ),
          if (grave.familyId != null) ...[
            SizedBox(height: 4.h(context)),
            Text(
              'معرّف العائلة: ${grave.familyId}',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                fontSize: 12.f(context),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
