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
        children: [
          Container(
            width: 120.w(context),
            height: 180.h(context),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(22.r(context)),
                bottomRight: Radius.circular(22.r(context)),
              ),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 52.ic(context)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16.w(context),
                16.h(context),
                16.w(context),
                16.h(context),
              ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.secondaryCharcoal,
                      fontSize: 12.f(context),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.f(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'الهدف 50,000',
                        style: TextStyle(
                          color: AppColors.primaryForest.withValues(alpha: 0.65),
                          fontSize: 11.f(context),
                        ),
                      ),
                    ],
                  ),
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
