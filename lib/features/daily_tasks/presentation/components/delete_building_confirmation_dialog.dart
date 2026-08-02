import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

Future<bool?> showDeleteBuildingConfirmationDialog(
  BuildContext context, {
  required String buildingName,
  required bool hasServerCopy,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: AppColors.primaryForest.withValues(alpha: 0.45),
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 28.w(context)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r(context)),
              border: Border.all(
                color: AppColors.thirdGoldenWheat.withValues(alpha: 0.9),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryForest.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20.w(context),
                    20.h(context),
                    20.w(context),
                    18.h(context),
                  ),
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24.r(context)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.s(context)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14.r(context)),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          AppIcons.buildings,
                          color: AppColors.thirdGoldenWheat,
                          size: 24.ic(context),
                        ),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تأكيد الحذف',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.f(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h(context)),
                            Text(
                              'إزالة المبنى من قائمة المسوحات',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12.f(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20.w(context),
                    18.h(context),
                    20.w(context),
                    20.h(context),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.s(context)),
                        decoration: BoxDecoration(
                          color: AppColors.thirdGoldenWheat
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(16.r(context)),
                          border: Border.all(
                            color: AppColors.primaryForest
                                .withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              buildingName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontSize: 15.f(context),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8.h(context)),
                            Text(
                              hasServerCopy
                                  ? 'سيتم حذف المبنى من قائمتك ومحاولة إزالته من الخادم أيضاً.'
                                  : 'سيتم حذف المبنى وبيانات المسح المرتبطة به من قائمتك.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.75),
                                fontSize: 13.f(context),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h(context)),
                      Text(
                        'لا يمكن التراجع عن هذا الإجراء.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryGoldenWheat,
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 20.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46.h(context),
                              child: OutlinedButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryForest,
                                  backgroundColor: AppColors.thirdGoldenWheat
                                      .withValues(alpha: 0.35),
                                  side: BorderSide(
                                    color: AppColors.primaryForest
                                        .withValues(alpha: 0.3),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14.r(context)),
                                  ),
                                ),
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14.f(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w(context)),
                          Expanded(
                            child: SizedBox(
                              height: 46.h(context),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  borderRadius:
                                      BorderRadius.circular(14.r(context)),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          AppColors.thirdDeepUmber,
                                          AppColors.alertRed,
                                          Color(0xFF8B3A2F),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(14.r(context)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.alertRed
                                              .withValues(alpha: 0.28),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'حذف',
                                        style: TextStyle(
                                          color: AppColors.thirdGoldenWheat,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.f(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
