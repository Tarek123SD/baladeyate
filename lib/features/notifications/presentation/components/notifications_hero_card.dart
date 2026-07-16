import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsHeroCard extends StatelessWidget {
  const NotificationsHeroCard({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    this.onMarkAllRead,
    this.isSubmitting = false,
  });

  final int totalCount;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final radius = 24.r(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned(
              top: -28.s(context),
              left: -18.s(context),
              child: _decorCircle(context, 110.s(context), 0.08),
            ),
            Positioned(
              bottom: -36.s(context),
              right: -24.s(context),
              child: _decorCircle(context, 80.s(context), 0.06),
            ),
            Padding(
              padding: EdgeInsets.all(20.s(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.s(context)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16.r(context)),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 28.ic(context),
                        ),
                      ),
                      SizedBox(width: 14.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'مركز التنبيهات',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.f(context),
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 4.h(context)),
                            Text(
                              'تابع آخر المستجدات والتحديثات',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12.f(context),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h(context)),
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      _StatPill(
                        label: 'الإجمالي',
                        value: '$totalCount',
                        icon: Icons.inbox_rounded,
                      ),
                      SizedBox(width: 10.w(context)),
                      _StatPill(
                        label: 'غير مقروء',
                        value: '$unreadCount',
                        icon: Icons.mark_email_unread_rounded,
                        highlight: unreadCount > 0,
                      ),
                    ],
                  ),
                  if (unreadCount > 0 && onMarkAllRead != null) ...[
                    SizedBox(height: 14.h(context)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: isSubmitting ? null : onMarkAllRead,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w(context),
                            vertical: 8.h(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r(context)),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        icon: isSubmitting
                            ? SizedBox(
                                width: 16.s(context),
                                height: 16.s(context),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.done_all_rounded,
                                size: 18.ic(context),
                              ),
                        label: Text(
                          'تحديد الكل كمقروء',
                          style: TextStyle(
                            fontSize: 13.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _decorCircle(BuildContext context, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 10.h(context),
        ),
        decoration: BoxDecoration(
          color: highlight
              ? AppColors.primaryGoldenWheat.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14.r(context)),
          border: Border.all(
            color: highlight
                ? AppColors.secondaryGoldenWheat.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              icon,
              size: 18.ic(context),
              color: Colors.white.withValues(alpha: 0.9),
            ),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.f(context),
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11.f(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
