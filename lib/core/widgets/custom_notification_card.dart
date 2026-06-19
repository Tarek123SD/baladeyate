import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomNotificationCard extends StatelessWidget {
  const CustomNotificationCard({
    super.key,
    required this.time,
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String time;
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final avatarRadius = 28.s(context);

    return Padding(
      padding: EdgeInsets.only(right: avatarRadius * 0.55),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              18.w(context),
              18.h(context),
              18.w(context),
              18.h(context),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20.r(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: const Color(0xFF7A7A7A),
                      fontSize: 12.f(context),
                    ),
                  ),
                ),
                SizedBox(height: 10.h(context)),
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.h(context)),
                Text(
                  message,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: const Color(0xFF5B5B5B),
                    fontSize: 14.f(context),
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -4.w(context),
            top: 14.h(context),
            child: CircleAvatar(
              radius: avatarRadius,
              backgroundColor: iconColor.withValues(alpha: 0.16),
              child: Icon(
                icon,
                size: avatarRadius.ic(context),
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
