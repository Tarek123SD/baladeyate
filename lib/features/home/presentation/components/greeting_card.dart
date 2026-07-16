import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Returns a time-aware Arabic greeting based on the current hour.
String timeAwareGreeting([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour >= 5 && hour < 12) return 'صباح الخير';
  if (hour >= 12 && hour < 17) return 'طاب يومك';
  if (hour >= 17 && hour < 21) return 'مساء الخير';
  return 'مساء الخير';
}

class GreetingCard extends StatelessWidget {
  const GreetingCard({
    super.key,
    required this.greeting,
    required this.name,
    this.userName,
    this.statusLabel = 'الهوية الرقمية مفعلة',
    this.statusColor = Colors.amber,
  });

  final String greeting;
  final String name;

  /// Raw user name used to render the avatar initial.
  final String? userName;
  final String statusLabel;
  final Color statusColor;

  String get _initial {
    final source = (userName ?? '').trim();
    if (source.isEmpty) return 'م';
    return source[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final radius = 24.r(context);

    return Container(
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
            color: AppColors.primaryForest.withValues(alpha: 0.35),
            blurRadius: 18.r(context),
            offset: Offset(0, 8.h(context)),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // Decorative circles for depth.
            Positioned(
              top: -30.s(context),
              left: -20.s(context),
              child: _decorCircle(120.s(context), 0.08),
            ),
            Positioned(
              bottom: -40.s(context),
              left: 40.s(context),
              child: _decorCircle(90.s(context), 0.06),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 18.s(context),
                vertical: 18.h(context),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  _avatar(context),
                  SizedBox(width: 14.s(context)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          greeting,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w400,
                                  ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 6.h(context)),
                        Text(
                          name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12.h(context)),
                        _statusChip(context),
                      ],
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

  Widget _avatar(BuildContext context) {
    final size = 56.s(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.f(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statusChip(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.s(context),
        vertical: 6.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.s(context),
            height: 8.s(context),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.6),
                  blurRadius: 6.r(context),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.s(context)),
          Flexible(
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
              textDirection: TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }
}
