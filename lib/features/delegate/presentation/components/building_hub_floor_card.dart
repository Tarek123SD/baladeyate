import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingHubFloorCard extends StatelessWidget {
  const BuildingHubFloorCard({
    super.key,
    required this.title,
    required this.saved,
    required this.expected,
    required this.onTap,
    required this.onEdit,
  });

  final String title;
  final int saved;
  final int expected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final progress = expected > 0
        ? (saved / expected).clamp(0.0, 1.0)
        : (saved > 0 ? 1.0 : 0.0);
    final subtitle = expected > 0 ? '$saved / $expected شقة' : '$saved شقة';

    return Material(
      color: Colors.transparent,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14.r(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r(context)),
        child: Ink(
          padding: EdgeInsets.fromLTRB(
            12.w(context),
            10.h(context),
            8.w(context),
            10.h(context),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r(context)),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 34.s(context),
                height: 34.s(context),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Icon(
                  AppIcons.layers,
                  color: AppColors.primaryForest,
                  size: 18.ic(context),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        color: AppColors.secondaryCharcoal
                            .withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (expected > 0) ...[
                      SizedBox(height: 6.h(context)),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6.r(context)),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4.h(context),
                          backgroundColor:
                              AppColors.primaryForest.withValues(alpha: 0.08),
                          color: progress >= 1
                              ? AppColors.thirdForest
                              : AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'تعديل',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  AppIcons.edit,
                  color: AppColors.primaryForest,
                  size: 18.ic(context),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primaryForest.withValues(alpha: 0.45),
                size: 20.ic(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
