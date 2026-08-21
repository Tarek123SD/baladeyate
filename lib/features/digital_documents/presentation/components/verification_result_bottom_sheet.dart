import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/digital_documents/models/verified_document_model.dart';

class VerificationResultBottomSheet {
  VerificationResultBottomSheet._();

  /// Shows success ModalBottomSheet for valid official document
  static Future<void> showSuccess(
    BuildContext context, {
    required VerifiedDocumentModel document,
    required VoidCallback onScanAnother,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w(bottomSheetContext),
              vertical: 24.h(bottomSheetContext),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r(bottomSheetContext)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Grab Handle
                Container(
                  width: 44.w(bottomSheetContext),
                  height: 4.h(bottomSheetContext),
                  margin: EdgeInsets.only(bottom: 20.h(bottomSheetContext)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Success Badge Icon
                Container(
                  padding: EdgeInsets.all(16.s(bottomSheetContext)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9), // Light green tint
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: 64.ic(bottomSheetContext),
                    color: const Color(0xFF2E7D32), // Dark emerald green
                  ),
                ),
                SizedBox(height: 16.h(bottomSheetContext)),

                // Success Title
                Text(
                  'وثيقة رسمية معتمدة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.f(bottomSheetContext),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 8.h(bottomSheetContext)),

                Text(
                  'تم التحقق بنجاح من صحة الوثيقة في السجلات الإلكترونية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.f(bottomSheetContext),
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 20.h(bottomSheetContext)),

                // Details Container Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.s(bottomSheetContext)),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16.r(bottomSheetContext)),
                    border: Border.all(
                      color: AppColors.inputBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        bottomSheetContext,
                        label: 'اسم المواطن',
                        value: document.citizenName,
                        icon: AppIcons.user,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        bottomSheetContext,
                        label: 'نوع الوثيقة',
                        value: document.documentType,
                        icon: AppIcons.notifTransaction,
                      ),
                      const Divider(height: 20),
                      _buildDetailRow(
                        bottomSheetContext,
                        label: 'رقم المعاملة',
                        value: document.transactionNumber,
                        icon: AppIcons.digitalDocs,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h(bottomSheetContext)),

                // Action Button: Scan Another Document
                SizedBox(
                  width: double.infinity,
                  height: 52.h(bottomSheetContext),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      onScanAnother();
                    },
                    icon: Icon(
                      AppIcons.scanDocument,
                      size: 20.ic(bottomSheetContext),
                      color: Colors.white,
                    ),
                    label: Text(
                      'مسح وثيقة أخرى',
                      style: TextStyle(
                        fontSize: 16.f(bottomSheetContext),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r(bottomSheetContext)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows error ModalBottomSheet for invalid/fake document
  static Future<void> showError(
    BuildContext context, {
    required String errorMessage,
    required VoidCallback onTryAgain,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w(bottomSheetContext),
              vertical: 24.h(bottomSheetContext),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28.r(bottomSheetContext)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Grab Handle
                Container(
                  width: 44.w(bottomSheetContext),
                  height: 4.h(bottomSheetContext),
                  margin: EdgeInsets.only(bottom: 20.h(bottomSheetContext)),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Error Warning Badge Icon
                Container(
                  padding: EdgeInsets.all(16.s(bottomSheetContext)),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE), // Light red tint
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gpp_bad_rounded,
                    size: 64.ic(bottomSheetContext),
                    color: AppColors.alertRed,
                  ),
                ),
                SizedBox(height: 16.h(bottomSheetContext)),

                // Error Title
                Text(
                  'وثيقة غير صالحة أو مزورة',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.f(bottomSheetContext),
                    fontWeight: FontWeight.bold,
                    color: AppColors.alertRed,
                  ),
                ),
                SizedBox(height: 12.h(bottomSheetContext)),

                // Error Description
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14.s(bottomSheetContext)),
                  decoration: BoxDecoration(
                    color: AppColors.alertRed.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12.r(bottomSheetContext)),
                    border: Border.all(
                      color: AppColors.alertRed.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.f(bottomSheetContext),
                      height: 1.4,
                      color: AppColors.primaryCharcoal,
                    ),
                  ),
                ),
                SizedBox(height: 24.h(bottomSheetContext)),

                // Action Button: Try Again
                SizedBox(
                  width: double.infinity,
                  height: 52.h(bottomSheetContext),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      onTryAgain();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      size: 20.ic(bottomSheetContext),
                      color: Colors.white,
                    ),
                    label: Text(
                      'إعادة المحاولة',
                      style: TextStyle(
                        fontSize: 16.f(bottomSheetContext),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryCharcoal,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r(bottomSheetContext)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.ic(context),
          color: AppColors.primaryGoldenWheat,
        ),
        SizedBox(width: 10.w(context)),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.f(context),
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryCharcoal,
            ),
          ),
        ),
      ],
    );
  }
}
