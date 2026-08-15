import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingComplexSaveBar extends StatelessWidget {
  const BuildingComplexSaveBar({
    super.key,
    required this.isSurveyMode,
    required this.isSaving,
    required this.onSave,
  });

  final bool isSurveyMode;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w(context)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isSurveyMode && !isSaving ? onSave : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppColors.green.withValues(alpha: 0.7),
            disabledForegroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              vertical: 14.h(context),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r(context)),
            ),
          ),
          child: isSaving
              ? SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.contrastingProgress(AppColors.green),
                  ),
                )
              : const Text('حفظ المبنى'),
        ),
      ),
    );
  }
}
