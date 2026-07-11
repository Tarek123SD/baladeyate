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
  });

  final String label;
  final String title;
  final String subtitle;
  final double progress;
  final String statusLabel;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final iconStripWidth = isMobile ? 88.w(context) : 112.w(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconStripWidth,
            constraints: BoxConstraints(minHeight: 120.h(context)),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(22.r(context)),
                bottomRight: Radius.circular(22.r(context)),
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: isMobile ? 40.ic(context) : 48.ic(context),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16.s(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w(context),
                      vertical: 4.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16.r(context)),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.f(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 15.f(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h(context)),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondaryCharcoal,
                      fontSize: 12.f(context),
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  _CampaignStatusRow(statusLabel: statusLabel),
                  SizedBox(height: 8.h(context)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r(context)),
                    child: LinearProgressIndicator(
                      minHeight: 6.h(context),
                      value: progress,
                      backgroundColor: AppColors.thirdGoldenWheat,
                      valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CampaignStatusRow extends StatelessWidget {
  const _CampaignStatusRow({required this.statusLabel});

  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 180.w(context);

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                statusLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.f(context),
                ),
              ),
              SizedBox(height: 4.h(context)),
              Text(
                'الهدف 50,000',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.primaryForest.withValues(alpha: 0.65),
                  fontSize: 11.f(context),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                statusLabel,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.f(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w(context)),
            Text(
              'الهدف 50,000',
              style: TextStyle(
                color: AppColors.primaryForest.withValues(alpha: 0.65),
                fontSize: 11.f(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
