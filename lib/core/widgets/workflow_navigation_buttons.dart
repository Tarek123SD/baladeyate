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
    final bool canGoNext = currentStep < totalSteps - 1;
    final bool canGoPrevious = currentStep > 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 16.h(context),
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE0E0E0),
            width: 1.h(context),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canGoNext && !isNextLoading ? onNext : null,
              icon: isNextLoading
                  ? SizedBox(
                      width: 18.w(context),
                      height: 18.w(context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canGoNext ? Colors.white : Colors.grey,
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
                backgroundColor:
                    canGoNext ? AppColors.primaryForest : Colors.grey[300],
                disabledBackgroundColor: Colors.grey[300],
                foregroundColor: canGoNext ? Colors.white : Colors.grey[600],
                disabledForegroundColor: Colors.grey[600],
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
                    ? AppColors.secondaryCharcoal
                    : Colors.grey[400],
                disabledForegroundColor: Colors.grey[400],
                side: BorderSide(
                  color: canGoPrevious
                      ? const Color(0xFFD0D0D0)
                      : Colors.grey[300]!,
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
