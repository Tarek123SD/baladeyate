import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationCampaignCard extends StatelessWidget {
  const CustomDonationCampaignCard({
    super.key,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.statusLabel,
    required this.icon,
    required this.iconColor,
    this.goalLabel,
    this.onDonate,
  });

  final String label;
  final String title;
  final String subtitle;
  final double progress;
  final String statusLabel;
  final IconData icon;
  final Color iconColor;
  final String? goalLabel;
  final VoidCallback? onDonate;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final percent = (clamped * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Padding(
              padding: EdgeInsets.fromLTRB(
                16.w(context),
                14.h(context),
                16.w(context),
                16.h(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (subtitle.trim().isNotEmpty) ...[
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.secondaryCharcoal,
                        fontSize: 12.5.f(context),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 14.h(context)),
                  ],
                  _buildProgress(context, clamped, percent),
                  if (onDonate != null) ...[
                    SizedBox(height: 16.h(context)),
                    _buildDonateButton(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            iconColor.withValues(alpha: 0.16),
            iconColor.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52.w(context),
            height: 52.w(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r(context)),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 28.ic(context)),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                _buildCategoryPill(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 4.h(context),
      ),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 13.ic(context)),
          SizedBox(width: 4.w(context)),
          Text(
            label,
            style: TextStyle(
              color: iconColor,
              fontWeight: FontWeight.bold,
              fontSize: 11.f(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(BuildContext context, double value, int percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w(context),
                vertical: 3.h(context),
              ),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r(context)),
              ),
              child: Text(
                '$percent%',
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.f(context),
                ),
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                goalLabel ?? statusLabel,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryForest.withValues(alpha: 0.7),
                  fontSize: 12.f(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h(context)),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r(context)),
          child: LinearProgressIndicator(
            minHeight: 9.h(context),
            value: value,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDonateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46.h(context),
      child: ElevatedButton.icon(
        onPressed: onDonate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r(context)),
          ),
        ),
        icon: Icon(Icons.volunteer_activism_rounded, size: 18.ic(context)),
        label: Text(
          'تبرع لهذه الحملة',
          style: TextStyle(
            fontSize: 13.5.f(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
