import 'dart:async';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
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

/// Step 2 of the password-reset flow.
///
/// Displays a 6-digit OTP field. On success the API returns a [reset_token]
/// that is forwarded to [NewResetPasswordScreen] (Step 3).
class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({
    super.key,
    required this.email,
    this.fromSettings = false,
  });

  final String email;
  final bool fromSettings;

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
    final success =
        await context.read<PasswordResetCubit>().sendOtp(widget.email);
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
            fromSettings: widget.fromSettings,
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
      child: AuthFlowScaffold(
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
                  const PasswordResetStepHeader(
                    step: 2,
                    title: 'التحقق من الرمز',
                    subtitle:
                        'أدخل رمز التحقق المكوّن من 6 أرقام الذي أُرسل إلى بريدك الإلكتروني',
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
                  BlocBuilder<PasswordResetCubit, PasswordResetState>(
                    buildWhen: (prev, curr) =>
                        (prev is PasswordResetLoading) !=
                        (curr is PasswordResetLoading),
                    builder: (context, state) {
                      final isLoading = state is PasswordResetLoading;
                      return PasswordResetPrimaryButton(
                        label: 'تحقق',
                        icon: Icons.verified_outlined,
                        isLoading: isLoading,
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
      ),
    );
  }
}
