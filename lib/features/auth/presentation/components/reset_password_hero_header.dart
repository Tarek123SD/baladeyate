import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Gradient hero banner at the top of [ResetPasswordScreen].
class ResetPasswordHeroHeader extends StatelessWidget {
  const ResetPasswordHeroHeader({
    super.key,
    required this.fromSettings,
    required this.otpSent,
  });

  final bool fromSettings;
  final bool otpSent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primaryForest,
            AppColors.secondaryForest,
            AppColors.thirdForest.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(22.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.s(context),
            height: 56.s(context),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16.r(context)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 28.s(context),
            ),
          ),
          SizedBox(width: 16.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fromSettings ? 'تغيير كلمة المرور' : 'إعادة تعيين كلمة المرور',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20.f(context),
                      ),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  otpSent
                      ? 'أدخل رمز التحقق وكلمة المرور الجديدة لإكمال العملية.'
                      : 'سنرسل رمز تحقق مكوّناً من 6 أرقام إلى بريدك الإلكتروني.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.5,
                        fontSize: 13.f(context),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.06, end: 0);
  }
}
