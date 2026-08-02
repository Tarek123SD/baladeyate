import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_logo_header.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_scaffold.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_screen_widgets.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_primary_button.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_step_header.dart';
import 'package:baladeyate/features/auth/presentation/verify_otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final cubit = context.read<PasswordResetCubit>();
    final email = _emailController.text.trim();
    final success = await cubit.sendOtp(email);
    if (!mounted || !success) return;

    // VerifyOtpScreen is pushed imperatively on top of the GoRouter-managed
    // /forgot-password page. The cubit is passed down explicitly so it is
    // shared across all 3 password-reset steps.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: VerifyOtpScreen(email: email),
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
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 20.s(context),
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  const AuthFlowLogoHeader(logoSize: 130),
                  SizedBox(height: 40.h(context)),
                  const PasswordResetStepHeader(
                    step: 1,
                    title: 'استعادة كلمة المرور',
                    subtitle:
                        'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّن من 6 أرقام',
                  ),
                  SizedBox(height: 28.h(context)),
                  const CustomFormFieldLabel(label: 'البريد الإلكتروني'),
                  SizedBox(height: 8.h(context)),
                  CustomTextfield(
                    controller: _emailController,
                    hint: 'example@gmail.com',
                    suffixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validator.email,
                  ),
                  SizedBox(height: 32.h(context)),
                  BlocBuilder<PasswordResetCubit, PasswordResetState>(
                    buildWhen: (prev, curr) =>
                        (prev is PasswordResetLoading) !=
                        (curr is PasswordResetLoading),
                    builder: (context, state) {
                      final isLoading = state is PasswordResetLoading;
                      return PasswordResetPrimaryButton(
                        label: 'إرسال رمز التحقق',
                        icon: Icons.send_rounded,
                        isLoading: isLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  SizedBox(height: 24.h(context)),
                  AuthSwitchLink(
                    prompt: 'تذكرت كلمة المرور؟ ',
                    actionLabel: 'تسجيل الدخول',
                    onTap: () => context.go('/login'),
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
