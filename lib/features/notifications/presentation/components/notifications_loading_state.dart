import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsLoadingState extends StatelessWidget {
  const NotificationsLoadingState({
    super.key,
    required this.horizontalPadding,
  });

  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16.h(context),
        horizontalPadding,
        24.h(context),
      ),
      children: [
        NotificationsSkeletonBox(height: 44.h(context), radius: 12.r(context)),
        SizedBox(height: 14.h(context)),
        Row(
          children: [
            Expanded(
              child: NotificationsSkeletonBox(
                height: 34.h(context),
                radius: 18,
              ),
            ),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: NotificationsSkeletonBox(
                height: 34.h(context),
                radius: 18,
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h(context)),
        for (var i = 0; i < 5; i++) ...[
          NotificationsSkeletonBox(
            height: 78.h(context),
            radius: 14.r(context),
          ),
          SizedBox(height: 8.h(context)),
        ],
      ],
    );
  }
}

class NotificationsSkeletonBox extends StatelessWidget {
  const NotificationsSkeletonBox({
    super.key,
    required this.height,
    required this.radius,
  });

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: Colors.white.withValues(alpha: 0.35),
        );
  }
}
