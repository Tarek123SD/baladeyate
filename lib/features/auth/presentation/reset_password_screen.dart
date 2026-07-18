import 'dart:async';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/password_input_field.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final success = await context.read<PasswordResetCubit>().resetPassword(
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

  double _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    var score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.length >= 12) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.15;
    return score.clamp(0, 1);
  }

  String _strengthLabel(double strength) {
    if (strength < 0.35) return 'ضعيفة';
    if (strength < 0.7) return 'متوسطة';
    return 'قوية';
  }

  Color _strengthColor(double strength) {
    if (strength < 0.35) return AppColors.alertRed;
    if (strength < 0.7) return AppColors.primaryGoldenWheat;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength(_passwordController.text);

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
              child: Directionality(
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
                          _buildHeroHeader(context),
                          SizedBox(height: 28.h(context)),
                          _buildEmailCard(context),
                          SizedBox(height: 16.h(context)),
                          _buildOtpCard(context),
                          SizedBox(height: 16.h(context)),
                          _buildPasswordCard(context, strength),
                          SizedBox(height: 28.h(context)),
                          _buildSubmitButton(context),
                          if (!widget.fromSettings) ...[
                            SizedBox(height: 20.h(context)),
                            _buildLoginLink(context),
                          ],
                        ],
                      ),
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

  Widget _buildHeroHeader(BuildContext context) {
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
                  widget.fromSettings
                      ? 'تغيير كلمة المرور'
                      : 'إعادة تعيين كلمة المرور',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20.f(context),
                      ),
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  _otpSent
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

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget child,
    int delayMs = 0,
  }) {
    return Container(
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
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: delayMs.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildEmailCard(BuildContext context) {
    return _buildSectionCard(
      context: context,
      icon: Icons.email_outlined,
      title: 'البريد الإلكتروني',
      delayMs: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomFormFieldLabel(label: 'عنوان البريد'),
          SizedBox(height: 8.h(context)),
          AbsorbPointer(
            absorbing: widget.fromSettings,
            child: Opacity(
              opacity: widget.fromSettings ? 0.75 : 1,
              child: CustomTextfield(
                controller: _emailController,
                hint: 'example@gmail.com',
                suffixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validator.email,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return _buildSectionCard(
      context: context,
      icon: Icons.sms_outlined,
      title: 'رمز التحقق',
      delayMs: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_otpSent)
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
          if (_otpSent) SizedBox(height: 12.h(context)),
          const CustomFormFieldLabel(label: 'أدخل الرمز المكوّن من 6 أرقام'),
          SizedBox(height: 8.h(context)),
          _buildOtpField(context),
          SizedBox(height: 10.h(context)),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildResendButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(BuildContext context) {
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
        controller: _otpController,
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
          fontSize: 22.f(context),
          fontWeight: FontWeight.w700,
          letterSpacing: 10,
        ),
        decoration: InputDecoration(
          hintText: '• • • • • •',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 18.f(context),
            letterSpacing: 6,
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
            vertical: 18.h(context),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(BuildContext context) {
    final canResend = !_isSendingOtp && _resendCooldown <= 0;

    return TextButton.icon(
      onPressed: canResend ? () => _sendOtp() : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondaryForest,
        disabledForegroundColor:
            AppColors.secondaryCharcoal.withValues(alpha: 0.45),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 6.h(context),
        ),
      ),
      icon: _isSendingOtp
          ? SizedBox(
              width: 16.s(context),
              height: 16.s(context),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.refresh_rounded,
              size: 18.s(context),
            ),
      label: Text(
        _isSendingOtp
            ? 'جاري الإرسال...'
            : _resendCooldown > 0
                ? 'إعادة الإرسال بعد $_resendCooldown ث'
                : _otpSent
                    ? 'إعادة إرسال الرمز'
                    : 'إرسال رمز التحقق',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.f(context),
        ),
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context, double strength) {
    return _buildSectionCard(
      context: context,
      icon: Icons.shield_outlined,
      title: 'كلمة المرور الجديدة',
      delayMs: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomFormFieldLabel(label: 'كلمة المرور'),
          SizedBox(height: 8.h(context)),
          PasswordInputField(
            controller: _passwordController,
            isVisible: _showPassword,
            onToggle: () => setState(() => _showPassword = !_showPassword),
            validator: Validator.password,
            hint: 'أدخل كلمة مرور قوية',
          ),
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 12.h(context)),
            _buildStrengthIndicator(context, strength),
          ],
          SizedBox(height: 16.h(context)),
          const CustomFormFieldLabel(label: 'تأكيد كلمة المرور'),
          SizedBox(height: 8.h(context)),
          PasswordInputField(
            controller: _confirmPasswordController,
            isVisible: _showConfirmPassword,
            onToggle: () => setState(
              () => _showConfirmPassword = !_showConfirmPassword,
            ),
            validator: (value) {
              final passwordError = Validator.password(value);
              if (passwordError != null) return passwordError;
              if (value != _passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
            hint: 'أعد إدخال كلمة المرور',
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator(BuildContext context, double strength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r(context)),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 6.h(context),
            backgroundColor: AppColors.inputBorder,
            color: _strengthColor(strength),
          ),
        ),
        SizedBox(height: 6.h(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قوة كلمة المرور',
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                fontSize: 12.f(context),
              ),
            ),
            Text(
              _strengthLabel(strength),
              style: TextStyle(
                color: _strengthColor(strength),
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      buildWhen: (previous, current) =>
          (previous is PasswordResetLoading) != (current is PasswordResetLoading),
      builder: (context, state) {
        final isSubmitting = state is PasswordResetLoading && !_isSendingOtp;

        return SizedBox(
          height: 56.h(context),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.secondaryForest,
              disabledBackgroundColor:
                  AppColors.secondaryForest.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r(context)),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 24.s(context),
                    height: 24.s(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 20.s(context),
                      ),
                      SizedBox(width: 10.w(context)),
                      Text(
                        'تأكيد كلمة المرور',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16.f(context),
                            ),
                      ),
                    ],
                  ),
          ),
        )
            .animate()
            .fadeIn(duration: 350.ms, delay: 240.ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/login'),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'تذكرت كلمة المرور؟ ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          children: [
            TextSpan(
              text: 'تسجيل الدخول',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryForest,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
