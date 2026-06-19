import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomSettingsOptionCard extends StatelessWidget {
  const CustomSettingsOptionCard({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final IconData leadingIcon;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: 14.w(context),
            vertical: 14.h(context),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 42.s(context),
            height: 42.s(context),
            decoration: BoxDecoration(
              color: AppColors.thirdGoldenWheat,
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
            child: Icon(
              leadingIcon,
              color: AppColors.primaryForest,
              size: 21.ic(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryForest,
                        fontWeight: FontWeight.w700,
                        fontSize: 15.f(context),
                      ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 3.h(context)),
                  Text(
                    subtitle!,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                          fontSize: 12.f(context),
                        ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w(context)),
          Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16.ic(context),
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
