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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 16.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE0E0E0),
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
                margin: EdgeInsets.symmetric(horizontal: 8.w(context)),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.primaryForest
                      : const Color(0xFFE0E0E0),
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
                    width: 44.w(context),
                    height: 44.w(context),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryForest
                          : isCompleted
                              ? AppColors.secondaryForest
                              : const Color(0xFFE8E8E8),
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
                          fontSize: 16.s(context),
                          fontWeight: FontWeight.w700,
                          color: isActive || isCompleted
                              ? Colors.white
                              : AppColors.secondaryCharcoal,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    steps[stepIndex],
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.s(context),
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
