import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsFilterChip extends StatelessWidget {
  const NotificationsFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18.r(context)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 8.h(context),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryForest : Colors.white,
              borderRadius: BorderRadius.circular(18.r(context)),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryForest
                    : AppColors.primaryForest.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryForest,
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (count > 0) ...[
                  SizedBox(width: 5.w(context)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w(context),
                      vertical: 1.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : (highlight
                              ? AppColors.alertRed.withValues(alpha: 0.1)
                              : AppColors.primaryForest
                                  .withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(10.r(context)),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (highlight
                                ? AppColors.alertRed
                                : AppColors.primaryForest),
                        fontSize: 10.f(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
