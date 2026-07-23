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
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r(context)),
        child: Padding(
          padding: EdgeInsets.all(18.s(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48.w(context),
                    height: 48.w(context),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r(context)),
                    ),
                    child: Icon(icon, color: iconColor, size: 24.ic(context)),
                  ),
                  SizedBox(width: 12.w(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.primaryForest,
                                  fontSize: 16.f(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w(context)),
                            _buildCategoryPill(context),
                          ],
                        ),
                        if (subtitle.trim().isNotEmpty) ...[
                          SizedBox(height: 6.h(context)),
                          Text(
                            subtitle,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: const Color(0xFF616161),
                              fontSize: 12.5.f(context),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h(context)),
              _buildProgress(context, clamped, percent),
              if (onDonate != null) ...[
                SizedBox(height: 16.h(context)),
                _buildDonateButton(context),
              ],
            ],
          ),
        ),
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
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 11.f(context),
        ),
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
            Text(
              '$percent%',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.bold,
                fontSize: 12.5.f(context),
              ),
            ),
            const Spacer(),
            Text(
              goalLabel ?? statusLabel,
              style: TextStyle(
                color: const Color(0xFF757575),
                fontSize: 12.f(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h(context)),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r(context)),
          child: LinearProgressIndicator(
            minHeight: 8.h(context),
            value: value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(iconColor),
          ),
        ),
      ],
    );
  }

  Widget _buildDonateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44.h(context),
      child: ElevatedButton.icon(
        onPressed: onDonate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
        ),
        icon: Icon(Icons.volunteer_activism_rounded, size: 18.ic(context)),
        label: Text(
          'تبرع لهذه الحملة',
          style: TextStyle(
            fontSize: 13.5.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
