import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
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

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _otpSent = widget.initialEmail?.isNotEmpty == true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final emailError = Validator.email(_emailController.text.trim());
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    final success = await context
        .read<PasswordResetCubit>()
        .sendOtp(_emailController.text.trim());
    if (!mounted || !success) return;

    setState(() => _otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رمز التحقق إلى بريدك الإلكتروني')),
    );
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
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
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
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                      ),
                      SizedBox(height: 12.h(context)),
                      Text(
                        'تغيير كلمة المرور',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryForest,
                            ),
                      ),
                      SizedBox(height: 8.h(context)),
                      Text(
                        'أدخل رمز التحقق المرسل إلى بريدك الإلكتروني وكلمة المرور الجديدة.',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      SizedBox(height: 32.h(context)),
                      const CustomFormFieldLabel(label: 'البريد الإلكتروني'),
                      SizedBox(height: 8.h(context)),
                      TextFormField(
                        controller: _emailController,
                        readOnly: widget.fromSettings,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validator.email,
                        decoration: _inputDecoration(context, 'example@gmail.com'),
                      ),
                      SizedBox(height: 12.h(context)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _sendOtp,
                          child: Text(
                            _otpSent ? 'إعادة إرسال الرمز' : 'إرسال رمز التحقق',
                          ),
                        ),
                      ),
                      const CustomFormFieldLabel(label: 'رمز التحقق'),
                      SizedBox(height: 8.h(context)),
                      TextFormField(
                        controller: _otpController,
                        textDirection: TextDirection.ltr,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: Validator.otp,
                        decoration: _inputDecoration(context, '123456'),
                      ),
                      SizedBox(height: 16.h(context)),
                      const CustomFormFieldLabel(label: 'كلمة المرور الجديدة'),
                      SizedBox(height: 8.h(context)),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        validator: Validator.password,
                        decoration: _inputDecoration(context, '••••••••').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() => _showPassword = !_showPassword);
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),
                      const CustomFormFieldLabel(label: 'تأكيد كلمة المرور'),
                      SizedBox(height: 8.h(context)),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        validator: (value) => Validator.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                        decoration: _inputDecoration(context, '••••••••').copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(
                                () => _showConfirmPassword = !_showConfirmPassword,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h(context)),
                      BlocBuilder<PasswordResetCubit, PasswordResetState>(
                        builder: (context, state) {
                          final isLoading = state is PasswordResetLoading;
                          return SizedBox(
                            height: 52.h(context),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryForest,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.r(context)),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text('تأكيد كلمة المرور'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.s(context),
        vertical: 16.s(context),
      ),
    );
  }
}
