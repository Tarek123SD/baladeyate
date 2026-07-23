import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationStatisticCard extends StatelessWidget {
  const CustomDonationStatisticCard({
    super.key,
    this.width,
    required this.value,
    required this.label,
    this.icon,
  });

  final double? width;
  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r(context)),
          child: Stack(
            children: [
              if (icon != null)
                Positioned(
                  left: -12.w(context),
                  bottom: -12.h(context),
                  child: Icon(
                    icon,
                    size: 64.ic(context),
                    color: AppColors.primaryForest.withValues(alpha: 0.06),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 18.h(context),
                  horizontal: 16.w(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 22.f(context),
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h(context)),
                    Text(
                      label,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF616161),
                        fontSize: 12.5.f(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
