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
    this.isRead = false,
    this.onTap,
  });

  final String time;
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = isRead
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r(context)),
        child: Ink(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18.r(context)),
            border: Border.all(
              color: isRead
                  ? const Color(0xFFE9E9E9)
                  : iconColor.withValues(alpha: 0.35),
              width: isRead ? 1 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isRead ? 0.03 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 14.w(context),
              vertical: 14.h(context),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46.s(context),
                  height: 46.s(context),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 24.ic(context),
                    color: iconColor,
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontSize: 15.f(context),
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead) ...[
                            SizedBox(width: 8.w(context)),
                            Container(
                              margin: EdgeInsets.only(top: 6.h(context)),
                              width: 9.s(context),
                              height: 9.s(context),
                              decoration: BoxDecoration(
                                color: AppColors.alertRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (message.isNotEmpty) ...[
                        SizedBox(height: 6.h(context)),
                        Text(
                          message,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0xFF5B5B5B),
                            fontSize: 13.f(context),
                            height: 1.6,
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h(context)),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13.ic(context),
                            color: const Color(0xFF9A9A9A),
                          ),
                          SizedBox(width: 4.w(context)),
                          Text(
                            time,
                            style: TextStyle(
                              color: const Color(0xFF9A9A9A),
                              fontSize: 11.f(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
