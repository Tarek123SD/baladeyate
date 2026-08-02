import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Compact notification row with clear unread/read hierarchy.
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
    final radius = 14.r(context);

    return Material(
      color: Colors.transparent,
      elevation: isRead ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isRead
                  ? Colors.black.withValues(alpha: 0.05)
                  : iconColor.withValues(alpha: 0.28),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isRead)
                  Container(
                    width: 4.w(context),
                    decoration: BoxDecoration(
                      color: iconColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(radius),
                        bottomRight: Radius.circular(radius),
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      11.w(context),
                      10.h(context),
                      10.w(context),
                      10.h(context),
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
                        SizedBox(width: 10.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isRead) ...[
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 5.h(context),
                                        left: 6.w(context),
                                      ),
                                      width: 7.s(context),
                                      height: 7.s(context),
                                      decoration: const BoxDecoration(
                                        color: AppColors.alertRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                  Expanded(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.primaryForest
                                            .withValues(
                                          alpha: isRead ? 0.7 : 1,
                                        ),
                                        fontSize: 13.f(context),
                                        fontWeight: isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (message.isNotEmpty) ...[
                                SizedBox(height: 4.h(context)),
                                Text(
                                  message,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.secondaryCharcoal
                                        .withValues(
                                      alpha: isRead ? 0.55 : 0.75,
                                    ),
                                    fontSize: 11.f(context),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              SizedBox(height: 6.h(context)),
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  if (typeLabel != null &&
                                      typeLabel!.isNotEmpty) ...[
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.w(context),
                                        vertical: 2.h(context),
                                      ),
                                      decoration: BoxDecoration(
                                        color: iconColor.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(10.r(context)),
                                      ),
                                      child: Text(
                                        typeLabel!,
                                        style: TextStyle(
                                          color: iconColor,
                                          fontSize: 9.f(context),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w(context)),
                                  ],
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 11.ic(context),
                                    color: AppColors.secondaryCharcoal
                                        .withValues(alpha: 0.45),
                                  ),
                                  SizedBox(width: 3.w(context)),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      color: AppColors.secondaryCharcoal
                                          .withValues(alpha: 0.55),
                                      fontSize: 10.f(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (!isRead)
                                    Text(
                                      'جديد',
                                      style: TextStyle(
                                        color: AppColors.alertRed,
                                        fontSize: 9.f(context),
                                        fontWeight: FontWeight.w800,
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
      width: 36.s(context),
      height: 36.s(context),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: isRead ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(10.r(context)),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18.ic(context),
        color: iconColor.withValues(alpha: isRead ? 0.7 : 1),
      ),
    );
  }
}
