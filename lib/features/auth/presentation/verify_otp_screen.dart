import 'dart:async';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/models/otp_flow_purpose.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_logo_header.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_scaffold.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_otp_field.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_primary_button.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_step_header.dart';
import 'package:baladeyate/features/auth/presentation/components/verify_otp_email_chip.dart';
import 'package:baladeyate/features/auth/presentation/components/verify_otp_resend_row.dart';
import 'package:baladeyate/features/auth/presentation/new_reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Shared OTP entry screen for password reset and login 2FA.
///
/// Only the title/copy changes. Widgets, countdown, resend, and errors stay
/// the same. [OtpFlowPurpose.login] must not reset a password;
/// [OtpFlowPurpose.passwordReset] must not log the user in.
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.fromSettings = false,
    this.purpose = OtpFlowPurpose.passwordReset,
    this.challengeToken,
  });

  final String email;
  final bool fromSettings;
  final OtpFlowPurpose purpose;
  final String? challengeToken;

  bool get isLogin => purpose == OtpFlowPurpose.login;

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
    final success = widget.isLogin
        ? await context.read<AuthCubit>().resendLoginOtp(
              email: widget.email,
              challengeToken: widget.challengeToken ?? '',
            )
        : await context.read<PasswordResetCubit>().sendOtp(widget.email);
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
    } else if (widget.isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إرسال رمز التحقق')),
      );
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

    if (widget.isLogin) {
      await context.read<AuthCubit>().verifyLoginOtp(
            email: widget.email,
            otp: _otpController.text.trim(),
            challengeToken: widget.challengeToken ?? '',
          );
      return;
    }

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
            fromSettings: widget.fromSettings,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isLogin ? 'تأكيد تسجيل الدخول' : 'التحقق من الرمز';
    final subtitle = widget.isLogin
        ? 'أدخل رمز التحقق المكوّن من 6 أرقام الذي أُرسل إلى بريدك الإلكتروني لإكمال تسجيل الدخول'
        : 'أدخل رمز التحقق المكوّن من 6 أرقام الذي أُرسل إلى بريدك الإلكتروني';

    final body = AuthFlowScaffold(
      body: SingleChildScrollView(
        child: ResponsiveBody(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                const AuthFlowLogoHeader(),
                SizedBox(height: 36.h(context)),
                PasswordResetStepHeader(
                  step: 2,
                  title: title,
                  subtitle: subtitle,
                ),
                SizedBox(height: 24.h(context)),
                VerifyOtpEmailChip(email: widget.email),
                SizedBox(height: 28.h(context)),
                const CustomFormFieldLabel(
                  label: 'أدخل الرمز المكوّن من 6 أرقام',
                ),
                SizedBox(height: 8.h(context)),
                PasswordResetOtpField(controller: _otpController),
                SizedBox(height: 32.h(context)),
                widget.isLogin
                    ? BlocBuilder<AuthCubit, AuthState>(
                        buildWhen: (prev, curr) =>
                            (prev is AuthLoading) != (curr is AuthLoading),
                        builder: (context, state) {
                          return PasswordResetPrimaryButton(
                            label: 'تحقق',
                            icon: Icons.verified_outlined,
                            isLoading: state is AuthLoading,
                            onPressed: _submit,
                          );
                        },
                      )
                    : BlocBuilder<PasswordResetCubit, PasswordResetState>(
                        buildWhen: (prev, curr) =>
                            (prev is PasswordResetLoading) !=
                            (curr is PasswordResetLoading),
                        builder: (context, state) {
                          return PasswordResetPrimaryButton(
                            label: 'تحقق',
                            icon: Icons.verified_outlined,
                            isLoading: state is PasswordResetLoading,
                            onPressed: _submit,
                          );
                        },
                      ),
                SizedBox(height: 20.h(context)),
                VerifyOtpResendRow(
                  canResend: _canResend,
                  secondsRemaining: _start,
                  onResend: resendOtp,
                ),
                SizedBox(height: 40.h(context)),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isLogin) {
      return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthSuccess && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        child: body,
      );
    }

    return BlocListener<PasswordResetCubit, PasswordResetState>(
      listener: (context, state) {
        if (state is PasswordResetFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<PasswordResetCubit>().clearFailure();
        }
      },
      child: body,
    );
  }
}
