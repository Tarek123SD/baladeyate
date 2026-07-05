import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Material 3 workflow step indicator for multi-step processes.
/// Shows a horizontal list of steps with connected dots/icons.
class WorkflowStepIndicator extends StatelessWidget {
  const WorkflowStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
  });

  /// List of step labels (e.g., ['Building', 'Floor', 'Apartment', 'People'])
  final List<String> steps;

  /// Current active step index (0-based)
  final int currentStep;

  /// Callback when a step is tapped
  final Function(int)? onStepTapped;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final stepSize = (screenWidth / (steps.length * 2.2)).clamp(32.0, 44.0);
    final labelSize = screenWidth < 360 ? 10.0 : 11.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: AppColors.thirdGoldenWheat,
            width: 1.h(context),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line between steps
            final int connectorIndex = index ~/ 2;
            final bool isCompleted = currentStep > connectorIndex;
            
            return Expanded(
              child: Container(
                height: 2.h(context),
                margin: EdgeInsets.symmetric(horizontal: 4.w(context)),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryForest
                      : AppColors.thirdGoldenWheat,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            );
          }

          // Step circle with label
          final int stepIndex = index ~/ 2;
          final bool isActive = currentStep == stepIndex;
          final bool isCompleted = currentStep > stepIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTapped?.call(stepIndex),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: stepSize,
                    height: stepSize,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryForest
                          : isCompleted
                              ? AppColors.secondaryForest
                              : AppColors.thirdGoldenWheat,
                      shape: BoxShape.circle,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primaryForest
                                    .withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: (stepSize * 0.38).clamp(13.0, 16.0),
                          fontWeight: FontWeight.w700,
                          color: isActive || isCompleted
                              ? Colors.white
                              : AppColors.secondaryCharcoal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    steps[stepIndex],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: labelSize.s(context),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive
                          ? AppColors.primaryForest
                          : AppColors.secondaryCharcoal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
