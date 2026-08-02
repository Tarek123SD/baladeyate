import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Confirmation dialog for submitting a complaint with acknowledgment checkbox.
Future<bool?> showComplaintSubmitConfirmationDialog(BuildContext context) {
  bool acknowledged = false;

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.r(context)),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: AppColors.primaryForest,
                    size: 22.ic(context),
                  ),
                  SizedBox(width: 8.s(context)),
                  Text(
                    'تأكيد الإقرار',
                    style: TextStyle(
                      fontSize: 17.f(context),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryForest,
                    ),
                  ),
                ],
              ),
              content: InkWell(
                borderRadius: BorderRadius.circular(12.r(context)),
                onTap: () =>
                    setDialogState(() => acknowledged = !acknowledged),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.s(context)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24.s(context),
                        height: 24.s(context),
                        child: Checkbox(
                          value: acknowledged,
                          activeColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r(context)),
                          ),
                          onChanged: (value) => setDialogState(
                            () => acknowledged = value ?? false,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.s(context)),
                      Expanded(
                        child: Text(
                          'المعلومات الواردة في هذه الشكوى صحيحة وأنا مسؤول عنها تماماً',
                          style: TextStyle(
                            fontSize: 13.f(context),
                            height: 1.6,
                            color: AppColors.secondaryCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: EdgeInsets.symmetric(
                horizontal: 16.s(context),
                vertical: 8.s(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 14.f(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: acknowledged
                      ? () => Navigator.of(dialogContext).pop(true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppColors.secondaryCharcoal.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                  ),
                  child: Text(
                    'إرسال',
                    style: TextStyle(
                      fontSize: 14.f(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
