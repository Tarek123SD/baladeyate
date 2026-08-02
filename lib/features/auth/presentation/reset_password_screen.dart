import 'dart:async';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_scaffold.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_screen_widgets.dart';
import 'package:baladeyate/features/auth/presentation/components/reset_password_email_card.dart';
import 'package:baladeyate/features/auth/presentation/components/reset_password_hero_header.dart';
import 'package:baladeyate/features/auth/presentation/components/reset_password_otp_card.dart';
import 'package:baladeyate/features/auth/presentation/components/reset_password_password_card.dart';
import 'package:baladeyate/features/auth/presentation/components/reset_password_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.fromSettings = false,
  });

  final String? initialEmail;
  final bool fromSettings;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _otpSent = false;
  bool _isSendingOtp = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    // OTP is already sent when arriving from the forgot-password flow.
    _otpSent =
        widget.initialEmail?.isNotEmpty == true && !widget.fromSettings;

    if (widget.fromSettings && widget.initialEmail?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendOtp(showSuccessSnackBar: true);
      });
    }

    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _sendOtp({bool showSuccessSnackBar = true}) async {
    if (_isSendingOtp || _resendCooldown > 0) return;

    final emailError = Validator.email(_emailController.text.trim());
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    setState(() => _isSendingOtp = true);
    final success = await context
        .read<PasswordResetCubit>()
        .sendOtp(_emailController.text.trim());
    if (!mounted) return;

    setState(() => _isSendingOtp = false);
    if (!success) return;

    setState(() => _otpSent = true);
    _startResendCooldown();

    if (showSuccessSnackBar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني'),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<PasswordResetCubit>().resetPasswordLegacy(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
    if (!mounted || !success) return;

    if (widget.fromSettings) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح')),
      );
      context.pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير كلمة المرور. يمكنك تسجيل الدخول الآن.'),
      ),
    );
    context.go('/login');
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
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 32.h(context)),
            child: ResponsiveBody(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 20.s(context),
                          color: AppColors.secondaryCharcoal,
                        ),
                      ),
                    ),
                    ResetPasswordHeroHeader(
                      fromSettings: widget.fromSettings,
                      otpSent: _otpSent,
                    ),
                    SizedBox(height: 28.h(context)),
                    ResetPasswordEmailCard(
                      controller: _emailController,
                      readOnly: widget.fromSettings,
                    ),
                    SizedBox(height: 16.h(context)),
                    ResetPasswordOtpCard(
                      otpController: _otpController,
                      otpSent: _otpSent,
                      isSendingOtp: _isSendingOtp,
                      resendCooldown: _resendCooldown,
                      onResend: () => _sendOtp(),
                    ),
                    SizedBox(height: 16.h(context)),
                    ResetPasswordPasswordCard(
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      showPassword: _showPassword,
                      showConfirmPassword: _showConfirmPassword,
                      onTogglePassword: () =>
                          setState(() => _showPassword = !_showPassword),
                      onToggleConfirmPassword: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword,
                      ),
                    ),
                    SizedBox(height: 28.h(context)),
                    ResetPasswordSubmitButton(
                      isSendingOtp: _isSendingOtp,
                      onPressed: _submit,
                    ),
                    if (!widget.fromSettings) ...[
                      SizedBox(height: 20.h(context)),
                      AuthSwitchLink(
                        prompt: 'تذكرت كلمة المرور؟ ',
                        actionLabel: 'تسجيل الدخول',
                        onTap: () => context.go('/login'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
