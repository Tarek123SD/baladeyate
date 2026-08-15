import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_otp_field.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_section_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResetPasswordOtpCard extends StatelessWidget {
  const ResetPasswordOtpCard({
    super.key,
    required this.otpController,
    required this.otpSent,
    required this.isSendingOtp,
    required this.resendCooldown,
    required this.onResend,
  });

  final TextEditingController otpController;
  final bool otpSent;
  final bool isSendingOtp;
  final int resendCooldown;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return PasswordResetSectionCard(
      icon: Icons.sms_outlined,
      title: 'رمز التحقق',
      animateDelayMs: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (otpSent)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w(context),
                vertical: 8.h(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r(context)),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.green,
                    size: 18.s(context),
                  ),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Text(
                      'تم إرسال الرمز — تحقق من بريدك الإلكتروني',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 12.f(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (otpSent) SizedBox(height: 12.h(context)),
          const CustomFormFieldLabel(label: 'أدخل الرمز المكوّن من 6 أرقام'),
          SizedBox(height: 8.h(context)),
          PasswordResetOtpField(
            controller: otpController,
            fontSize: 22,
            letterSpacing: 10,
            hintFontSize: 18,
            hintLetterSpacing: 6,
            verticalPadding: 18,
          ),
          SizedBox(height: 10.h(context)),
          Align(
            alignment: Alignment.centerLeft,
            child: ResetPasswordResendButton(
              otpSent: otpSent,
              isSendingOtp: isSendingOtp,
              resendCooldown: resendCooldown,
              onResend: onResend,
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordResendButton extends StatelessWidget {
  const ResetPasswordResendButton({
    super.key,
    required this.otpSent,
    required this.isSendingOtp,
    required this.resendCooldown,
    required this.onResend,
  });

  final bool otpSent;
  final bool isSendingOtp;
  final int resendCooldown;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final canResend = !isSendingOtp && resendCooldown <= 0;

    return TextButton.icon(
      onPressed: canResend ? onResend : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryForest,
        disabledForegroundColor:
            AppColors.secondaryCharcoal.withValues(alpha: 0.45),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 6.h(context),
        ),
      ),
      icon: isSendingOtp
          ? SizedBox(
              width: 16.s(context),
              height: 16.s(context),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.pageProgress(context),
              ),
            )
          : Icon(
              Icons.refresh_rounded,
              size: 18.s(context),
            ),
      label: Text(
        isSendingOtp
            ? 'جاري الإرسال...'
            : resendCooldown > 0
                ? 'إعادة الإرسال بعد $resendCooldown ث'
                : otpSent
                    ? 'إعادة إرسال الرمز'
                    : 'إرسال رمز التحقق',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.f(context),
        ),
      ),
    );
  }
}
