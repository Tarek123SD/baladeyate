import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

Future<bool?> showStartSurveySheet(
  BuildContext context, {
  required LatLng position,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    showDragHandle: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r(context)),
      ),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20.w(context),
          8.h(context),
          20.w(context),
          24.h(context) + MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'نقطة مسح جديدة',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 18.f(context),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h(context)),
            Text(
              'خط العرض: ${position.latitude.toStringAsFixed(5)}\nخط الطول: ${position.longitude.toStringAsFixed(5)}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
                fontSize: 14.f(context),
                height: 1.6,
              ),
            ),
            SizedBox(height: 20.h(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(sheetContext).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                ),
                child: Text(
                  'بدء إدخال البيانات',
                  style: TextStyle(
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
