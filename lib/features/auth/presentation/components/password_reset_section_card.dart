import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// White content card with icon + title used on password-reset screens.
class PasswordResetSectionCard extends StatelessWidget {
  const PasswordResetSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.animateDelayMs,
  });

  final IconData icon;
  final String title;
  final Widget child;

  /// When set, fades/slides the card in after this delay.
  final int? animateDelayMs;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: EdgeInsets.all(18.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36.s(context),
                height: 36.s(context),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Icon(
                  icon,
                  size: 18.s(context),
                  color: AppColors.primaryForest,
                ),
              ),
              SizedBox(width: 10.w(context)),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primaryForest,
                      fontWeight: FontWeight.w700,
                      fontSize: 15.f(context),
                    ),
              ),
            ],
          ),
          SizedBox(height: 16.h(context)),
          child,
        ],
      ),
    );

    final delay = animateDelayMs;
    if (delay != null) {
      card = card
          .animate()
          .fadeIn(duration: 350.ms, delay: delay.ms)
          .slideY(begin: 0.06, end: 0);
    }

    return card;
  }
}
