import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.greeting,
    required this.name,
    this.statusLabel = 'الهوية الرقمية مفعلة',
    this.statusColor = Colors.amber,
  });

  final String greeting;
  final String name;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.s(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryForest,
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.s(context),
                height: 8.s(context),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.s(context)),
              Text(
                statusLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
