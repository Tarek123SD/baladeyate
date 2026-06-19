import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable card container for form sections with header, badge support.
class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.badge,
    this.badgeColor,
  });

  /// Card title (e.g., 'Building File')
  final String title;

  /// Main content widget
  final Widget child;

  /// Optional badge text (e.g., 'Under Inspection')
  final String? badge;

  /// Badge background color
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 12.h(context),
      ),
      padding: EdgeInsets.all(24.w(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: const Color(0xFFE6E6E6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18.s(context),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryForest,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w(context),
                    vertical: 6.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.secondaryGoldenWheat,
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                  child: Text(
                    badge!,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 11.s(context),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h(context)),
          child,
        ],
      ),
    );
  }
}
