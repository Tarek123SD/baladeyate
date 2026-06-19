import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable info card for displaying information with icon and content.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.onTap,
  });

  /// Icon to display
  final IconData icon;

  /// Card title (e.g., 'Last Inspection')
  final String title;

  /// Card subtitle/content
  final String subtitle;

  /// Icon background color
  final Color? iconColor;

  /// Tap callback
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16.w(context),
          vertical: 10.h(context),
        ),
        padding: EdgeInsets.all(16.w(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: const Color(0xFFE6E6E6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.s(context),
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    subtitle,
                    textDirection: TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.s(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryForest,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w(context)),
            Container(
              width: 44.w(context),
              height: 44.w(context),
              decoration: BoxDecoration(
                color: iconColor ?? AppColors.primaryForest.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryForest,
                size: 22.s(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
