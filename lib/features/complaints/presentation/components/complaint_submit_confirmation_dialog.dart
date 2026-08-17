import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Confirmation dialog for submitting a complaint with acknowledgment checkbox.
Future<bool?> showComplaintSubmitConfirmationDialog(BuildContext context) {
  var acknowledged = false;

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
              contentPadding: EdgeInsets.fromLTRB(
                20.s(context),
                20.s(context),
                20.s(context),
                16.s(context),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.primaryForest,
                        size: 22.ic(context),
                      ),
                      SizedBox(width: 8.s(context)),
                      Expanded(
                        child: Text(
                          'تأكيد الإقرار',
                          style: TextStyle(
                            fontSize: 17.f(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryForest,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.s(context)),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r(context)),
                      onTap: () => setDialogState(
                        () => acknowledged = !acknowledged,
                      ),
                      child: Ink(
                        padding: EdgeInsets.all(12.s(context)),
                        decoration: BoxDecoration(
                          color: acknowledged
                              ? AppColors.green.withValues(alpha: 0.08)
                              : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(12.r(context)),
                          border: Border.all(
                            color: acknowledged
                                ? AppColors.green
                                : AppColors.inputBorder,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AcknowledgmentCheckbox(checked: acknowledged),
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
                  ),
                  SizedBox(height: 18.s(context)),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 44.h(context),
                          child: ElevatedButton(
                            onPressed: acknowledged
                                ? () => Navigator.of(dialogContext).pop(true)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors
                                  .secondaryCharcoal
                                  .withValues(alpha: 0.3),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12.r(context),
                                ),
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
                        ),
                      ),
                      SizedBox(width: 10.s(context)),
                      Expanded(
                        child: SizedBox(
                          height: 44.h(context),
                          child: TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: 14.f(context),
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryCharcoal,
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
          );
        },
      );
    },
  );
}

class _AcknowledgmentCheckbox extends StatelessWidget {
  const _AcknowledgmentCheckbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final boxSize = 22.s(context);

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.only(top: 2.s(context)),
      decoration: BoxDecoration(
        color: checked ? AppColors.green : Colors.white,
        borderRadius: BorderRadius.circular(6.r(context)),
        border: Border.all(
          color: checked ? AppColors.green : AppColors.primaryForest,
          width: 1.5,
        ),
      ),
      child: checked
          ? Icon(
              Icons.check,
              size: 16.s(context),
              color: Colors.white,
            )
          : null,
    );
  }
}
