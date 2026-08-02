import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Delete confirmation dialog for a complaint.
Future<bool?> showComplaintDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r(dialogContext)),
          ),
          contentPadding: EdgeInsets.fromLTRB(
            20.w(dialogContext),
            20.h(dialogContext),
            20.w(dialogContext),
            8.h(dialogContext),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(14.s(dialogContext)),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 32.ic(dialogContext),
                ),
              ),
              SizedBox(height: 16.h(dialogContext)),
              Text(
                'حذف الشكوى',
                style: TextStyle(
                  fontSize: 18.f(dialogContext),
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryForest,
                ),
              ),
              SizedBox(height: 8.h(dialogContext)),
              Text(
                'هل أنت متأكد من حذف هذه الشكوى؟ لا يمكن التراجع عن هذا الإجراء.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.f(dialogContext),
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            16.w(dialogContext),
            0,
            16.w(dialogContext),
            16.h(dialogContext),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 14.f(dialogContext),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(dialogContext)),
                ),
              ),
              child: Text(
                'حذف',
                style: TextStyle(
                  fontSize: 14.f(dialogContext),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
