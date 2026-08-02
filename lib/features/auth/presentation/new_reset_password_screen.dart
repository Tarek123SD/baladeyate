import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_logo_header.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_flow_scaffold.dart';
import 'package:baladeyate/features/auth/presentation/components/new_reset_password_fields_card.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_primary_button.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Step 3 of the password-reset flow.
///
/// Requires [email] and [resetToken] (returned by the verify-OTP step).
/// On success shows a SnackBar and clears the navigation stack back to [AuthScreen].
class NewResetPasswordScreen extends StatefulWidget {
  const NewResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  final String email;
  final String resetToken;

  @override
  State<NewResetPasswordScreen> createState() => _NewResetPasswordScreenState();
}

class _NewResetPasswordScreenState extends State<NewResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Rebuild the strength indicator on every keystroke.
    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<PasswordResetCubit>().resetPassword(
          email: widget.email,
          resetToken: widget.resetToken,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.'),
        backgroundColor: AppColors.secondaryForest,
      ),
    );

    // Use GoRouter to navigate to /login so the route tree's BlocProviders
    // (AuthFormCubit, etc.) are properly created. context.go replaces the
    // entire stack, clearing the Navigator-pushed screens as well.
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
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.h(context)),
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
                    step: 3,
                    title: 'تغيير كلمة المرور',
                    subtitle:
                        'أدخل كلمة المرور الجديدة وتأكيدها لإكمال العملية',
                  ),
                  SizedBox(height: 28.h(context)),
                  NewResetPasswordFieldsCard(
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
                  BlocBuilder<PasswordResetCubit, PasswordResetState>(
                    buildWhen: (prev, curr) =>
                        (prev is PasswordResetLoading) !=
                        (curr is PasswordResetLoading),
                    builder: (context, state) {
                      final isLoading = state is PasswordResetLoading;
                      return PasswordResetPrimaryButton(
                        label: 'تغيير كلمة المرور',
                        icon: Icons.lock_reset_rounded,
                        isLoading: isLoading,
                        onPressed: _submit,
                      );
                    },
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
