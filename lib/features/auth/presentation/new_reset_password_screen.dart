import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/password_input_field.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
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

  // ── Password strength helpers ────────────────────────────────────────────

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

  String _strengthLabel(double s) {
    if (s < 0.35) return 'ضعيفة';
    if (s < 0.70) return 'متوسطة';
    return 'قوية';
  }

  Color _strengthColor(double s) {
    if (s < 0.35) return AppColors.alertRed;
    if (s < 0.70) return AppColors.primaryGoldenWheat;
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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 32.h(context)),
                child: ResponsiveBody(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ── Back arrow ─────────────────────────────────────
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

                        // ── Logo ───────────────────────────────────────────
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

                        // ── Step 3 header ──────────────────────────────────
                        _StepHeader(
                          step: 3,
                          title: 'تغيير كلمة المرور',
                          subtitle:
                              'أدخل كلمة المرور الجديدة وتأكيدها لإكمال العملية',
                        ),

                        SizedBox(height: 28.h(context)),

                        // ── Password card ──────────────────────────────────
                        _SectionCard(
                          icon: Icons.shield_outlined,
                          title: 'كلمة المرور الجديدة',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const CustomFormFieldLabel(
                                  label: 'كلمة المرور'),
                              SizedBox(height: 8.h(context)),
                              PasswordInputField(
                                controller: _passwordController,
                                isVisible: _showPassword,
                                onToggle: () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                                validator: Validator.password,
                                hint: 'أدخل كلمة مرور قوية',
                              ),

                              // Strength indicator
                              if (_passwordController.text.isNotEmpty) ...[
                                SizedBox(height: 12.h(context)),
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(6.r(context)),
                                  child: LinearProgressIndicator(
                                    value: strength,
                                    minHeight: 6.h(context),
                                    backgroundColor: AppColors.inputBorder,
                                    color: _strengthColor(strength),
                                  ),
                                ),
                                SizedBox(height: 6.h(context)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'قوة كلمة المرور',
                                      style: TextStyle(
                                        color: AppColors.secondaryCharcoal
                                            .withValues(alpha: 0.7),
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

                              SizedBox(height: 16.h(context)),
                              const CustomFormFieldLabel(
                                  label: 'تأكيد كلمة المرور'),
                              SizedBox(height: 8.h(context)),
                              PasswordInputField(
                                controller: _confirmPasswordController,
                                isVisible: _showConfirmPassword,
                                onToggle: () => setState(
                                  () => _showConfirmPassword =
                                      !_showConfirmPassword,
                                ),
                                validator: (value) {
                                  final error = Validator.password(value);
                                  if (error != null) return error;
                                  if (value != _passwordController.text) {
                                    return 'كلمتا المرور غير متطابقتين';
                                  }
                                  return null;
                                },
                                hint: 'أعد إدخال كلمة المرور',
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28.h(context)),

                        // ── Submit button ──────────────────────────────────
                        BlocBuilder<PasswordResetCubit, PasswordResetState>(
                          buildWhen: (prev, curr) =>
                              (prev is PasswordResetLoading) !=
                              (curr is PasswordResetLoading),
                          builder: (context, state) {
                            final isLoading = state is PasswordResetLoading;
                            return _PrimaryButton(
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
          ),
        ],
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
