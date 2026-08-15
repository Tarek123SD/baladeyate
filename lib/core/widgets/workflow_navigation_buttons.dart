import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable navigation buttons for workflow (Previous/Next).
class WorkflowNavigationButtons extends StatelessWidget {
  const WorkflowNavigationButtons({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.currentStep,
    required this.totalSteps,
    this.isNextLoading = false,
    this.nextLabel = 'التالي',
    this.previousLabel = 'السابق',
  });

  /// Callback when Next button is pressed
  final VoidCallback onNext;

  /// Callback when Previous button is pressed
  final VoidCallback onPrevious;

  /// Current step index (0-based)
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Whether the Next button is loading
  final bool isNextLoading;

  /// Next button label
  final String nextLabel;

  /// Previous button label
  final String previousLabel;

  @override
  Widget build(BuildContext context) {
    final bool canGoPrevious = currentStep > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 16.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: Border(
          top: BorderSide(
            color: AppColors.thirdGoldenWheat,
            width: 1.h(context),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isNextLoading ? null : onNext,
              icon: isNextLoading
                  ? SizedBox(
                      width: 18.w(context),
                      height: 18.w(context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.contrastingProgress(
                          AppColors.primaryForest,
                        ),
                      ),
                    )
                  : Icon(Icons.arrow_back_rounded, size: 20.s(context)),
              label: Text(
                nextLabel,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.s(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                disabledBackgroundColor:
                    AppColors.primaryForest.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w(context),
                  vertical: 12.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canGoPrevious ? onPrevious : null,
              icon: Icon(Icons.arrow_forward_rounded, size: 20.s(context)),
              label: Text(
                previousLabel,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14.s(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: canGoPrevious
                    ? AppColors.primaryForest
                    : AppColors.secondaryCharcoal.withValues(alpha: 0.4),
                disabledForegroundColor:
                    AppColors.secondaryCharcoal.withValues(alpha: 0.4),
                side: BorderSide(
                  color: canGoPrevious
                      ? AppColors.primaryForest
                      : AppColors.thirdGoldenWheat,
                  width: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w(context),
                  vertical: 12.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
