import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Prominent call-to-action shown when the current user still needs to
/// verify their national identity. Routes to the verification flow on tap.
class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key, this.wasRejected = false});

  /// When the previous verification attempt was rejected we adjust the copy.
  final bool wasRejected;

  @override
  Widget build(BuildContext context) {
    final radius = 20.r(context);
    final title = wasRejected ? 'تم رفض توثيق الهوية' : 'وثّق هويتك الوطنية';
    final subtitle = wasRejected
        ? 'يرجى إعادة إرسال بيانات الهوية للمتابعة.'
        : 'فعّل جميع الخدمات وقدّم الشكاوى بعد توثيق هويتك.';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/verify-identity'),
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: EdgeInsets.all(16.s(context)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.secondaryGoldenWheat,
                AppColors.primaryGoldenWheat,
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGoldenWheat.withValues(alpha: 0.35),
                blurRadius: 14.r(context),
                offset: Offset(0, 6.h(context)),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 46.s(context),
                height: 46.s(context),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  wasRejected
                      ? Icons.gpp_maybe_outlined
                      : Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 26.s(context),
                ),
              ),
              SizedBox(width: 14.s(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.s(context)),
              Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16.s(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
