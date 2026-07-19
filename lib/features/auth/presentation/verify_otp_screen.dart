import 'dart:async';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/presentation/new_reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Step 2 of the password-reset flow.
///
/// Displays a 6-digit OTP field. On success the API returns a [reset_token]
/// that is forwarded to [NewResetPasswordScreen] (Step 3).
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _start = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _start = 60;
    _canResend = false;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            _canResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> resendOtp() async {
    final success = await context.read<PasswordResetCubit>().sendOtp(widget.email);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إعادة إرسال رمز التحقق بنجاح',
            style: TextStyle(fontFamily: 'Tajawal'),
          ),
          backgroundColor: AppColors.secondaryForest,
        ),
      );
      startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final fetchedToken = await context.read<PasswordResetCubit>().verifyOtp(
          email: widget.email,
          otp: _otpController.text.trim(),
        );
    if (!mounted || fetchedToken == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<PasswordResetCubit>(),
          child: NewResetPasswordScreen(
            email: widget.email,
            resetToken: fetchedToken,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordResetCubit, PasswordResetState>(
      listener: (context, state) {
        if (state is PasswordResetFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<PasswordResetCubit>().clearFailure();
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.backgroundWhite),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                child: ResponsiveBody(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Back arrow ───────────────────────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 20.s(context),
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h(context)),

                        // ── Logo ─────────────────────────────────────────────
                        Image.asset(
                          AppAssets.logoGold,
                          width: 110.s(context),
                          height: 110.s(context),
                        ),
                        SizedBox(height: 20.h(context)),
                        Text(
                          'بلديتي',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 6.h(context)),
                        Text(
                          'الجمهورية العربية السورية',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                          textDirection: TextDirection.rtl,
                        ),

                        SizedBox(height: 36.h(context)),

                        // ── Step 2 header ────────────────────────────────────
                        _StepHeader(
                          step: 2,
                          title: 'التحقق من الرمز',
                          subtitle:
                              'أدخل رمز التحقق المكوّن من 6 أرقام الذي أُرسل إلى بريدك الإلكتروني',
                        ),

                        SizedBox(height: 24.h(context)),

                        // ── Email chip (read-only display) ───────────────────
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w(context),
                            vertical: 10.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryForest.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12.r(context)),
                            border: Border.all(
                              color: AppColors.secondaryForest.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 16.s(context),
                                color: AppColors.secondaryForest,
                              ),
                              SizedBox(width: 8.w(context)),
                              Text(
                                widget.email,
                                style: TextStyle(
                                  color: AppColors.secondaryForest,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.f(context),
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h(context)),

                        // ── OTP field label ──────────────────────────────────
                        const CustomFormFieldLabel(
                          label: 'أدخل الرمز المكوّن من 6 أرقام',
                        ),
                        SizedBox(height: 8.h(context)),

                        // ── OTP input ────────────────────────────────────────
                        _OtpField(controller: _otpController),

                        SizedBox(height: 32.h(context)),

                        // ── Verify button ────────────────────────────────────
                        BlocBuilder<PasswordResetCubit, PasswordResetState>(
                          buildWhen: (prev, curr) =>
                              (prev is PasswordResetLoading) !=
                              (curr is PasswordResetLoading),
                          builder: (context, state) {
                            final isLoading = state is PasswordResetLoading;
                            return _PrimaryButton(
                              label: 'تحقق',
                              icon: Icons.verified_outlined,
                              isLoading: isLoading,
                              onPressed: _submit,
                            );
                          },
                        ),
                        SizedBox(height: 20.h(context)),

                        // ── Resend OTP ───────────────────────────────────────
                        Center(
                          child: _canResend
                              ? TextButton(
                                  onPressed: resendOtp,
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.secondaryForest,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.f(context),
                                    ),
                                  ),
                                  child: const Text('إعادة إرسال الرمز'),
                                )
                              : Text(
                                  'إعادة إرسال الرمز خلال $_start ثانية',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14.f(context),
                                  ),
                                ),
                        ),

                        SizedBox(height: 40.h(context)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── OTP field ──────────────────────────────────────────────────────────────

class _OtpField extends StatelessWidget {
  const _OtpField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        validator: Validator.otp,
        cursorColor: AppColors.secondaryForest,
        style: TextStyle(
          color: Colors.black,
          fontSize: 26.f(context),
          fontWeight: FontWeight.w700,
          letterSpacing: 12,
        ),
        decoration: InputDecoration(
          hintText: '• • • • • •',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 20.f(context),
            letterSpacing: 8,
          ),
          filled: true,
          fillColor: AppColors.inputFill,
          counterText: '',
          prefixIcon: Icon(
            Icons.pin_outlined,
            color: AppColors.secondaryForest,
            size: 20.s(context),
          ),
          border: outline(AppColors.inputBorder, 1.4),
          enabledBorder: outline(AppColors.inputBorder, 1.4),
          focusedBorder: outline(AppColors.inputFocusedBorder, 1.8),
          errorBorder: outline(AppColors.alertRed, 1.4),
          focusedErrorBorder: outline(AppColors.alertRed, 1.8),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w(context),
            vertical: 20.h(context),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets (scoped to this file) ────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final int step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          SizedBox(width: 14.s(context)),
          Column(
            children: [
              Container(
                width: 36.s(context),
                height: 36.s(context),
                decoration: BoxDecoration(
                  color: AppColors.secondaryForest,
                  borderRadius: BorderRadius.circular(10.r(context)),
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.f(context),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h(context)),
              Container(
                width: 3.s(context),
                height: 50.h(context),
                color: AppColors.thirdForest,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h(context),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryForest,
          disabledBackgroundColor:
              AppColors.secondaryForest.withValues(alpha: 0.6),
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r(context)),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20.s(context), color: Colors.white),
                  SizedBox(width: 10.s(context)),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16.f(context),
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
