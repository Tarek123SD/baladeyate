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
    this.typeLabel,
    this.isRead = false,
    this.onTap,
  });

  final String time;
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String? typeLabel;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = 20.r(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white.withValues(alpha: 0.65)
                : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isRead
                  ? AppColors.primaryForest.withValues(alpha: 0.06)
                  : iconColor.withValues(alpha: 0.28),
              width: isRead ? 1 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isRead
                    ? Colors.black.withValues(alpha: 0.03)
                    : iconColor.withValues(alpha: 0.12),
                blurRadius: isRead ? 10 : 18,
                offset: Offset(0, isRead ? 4 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                if (!isRead)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 4.w(context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            iconColor,
                            iconColor.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w(context),
                    14.h(context),
                    16.w(context),
                    14.h(context),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      _IconBadge(
                        icon: icon,
                        iconColor: iconColor,
                        isRead: isRead,
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                if (!isRead)
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 8.w(context),
                                      top: 6.h(context),
                                    ),
                                    width: 8.s(context),
                                    height: 8.s(context),
                                    decoration: BoxDecoration(
                                      color: AppColors.alertRed,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.alertRed
                                              .withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
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
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (typeLabel != null && typeLabel!.isNotEmpty) ...[
                              SizedBox(height: 6.h(context)),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w(context),
                                    vertical: 4.h(context),
                                  ),
                                  decoration: BoxDecoration(
                                    color: iconColor.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(20.r(context)),
                                  ),
                                  child: Text(
                                    typeLabel!,
                                    style: TextStyle(
                                      color: iconColor,
                                      fontSize: 10.f(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (message.isNotEmpty) ...[
                              SizedBox(height: 8.h(context)),
                              Text(
                                message,
                                textAlign: TextAlign.right,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: isRead ? 0.65 : 0.8),
                                  fontSize: 13.f(context),
                                  height: 1.55,
                                ),
                              ),
                            ],
                            SizedBox(height: 10.h(context)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              textDirection: TextDirection.rtl,
                              children: [
                                if (!isRead) ...[
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w(context),
                                      vertical: 3.h(context),
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.alertRed
                                          .withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(8.r(context)),
                                    ),
                                    child: Text(
                                      'جديد',
                                      style: TextStyle(
                                        color: AppColors.alertRed,
                                        fontSize: 10.f(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w(context)),
                                ],
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 13.ic(context),
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: 0.45),
                                ),
                                SizedBox(width: 4.w(context)),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: AppColors.secondaryCharcoal
                                        .withValues(alpha: 0.55),
                                    fontSize: 11.f(context),
                                    fontWeight: FontWeight.w500,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.iconColor,
    required this.isRead,
  });

  final IconData icon;
  final Color iconColor;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.s(context),
      height: 48.s(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            iconColor.withValues(alpha: isRead ? 0.12 : 0.22),
            iconColor.withValues(alpha: isRead ? 0.06 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(15.r(context)),
        border: Border.all(
          color: iconColor.withValues(alpha: isRead ? 0.15 : 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 24.ic(context),
        color: iconColor,
      ),
    );
  }
}
