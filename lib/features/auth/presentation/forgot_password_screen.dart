import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
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
                        // ── Back arrow ──────────────────────────────────────
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

                        // ── Logo ────────────────────────────────────────────
                        Image.asset(
                          AppAssets.logoGold,
                          width: 130.s(context),
                          height: 130.s(context),
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

                        SizedBox(height: 40.h(context)),

                        // ── Step header ──────────────────────────────────────
                        _StepHeader(
                          step: 1,
                          title: 'استعادة كلمة المرور',
                          subtitle:
                              'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّن من 6 أرقام',
                        ),

                        SizedBox(height: 28.h(context)),

                        // ── Email field ─────────────────────────────────────
                        const CustomFormFieldLabel(
                            label: 'البريد الإلكتروني'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _emailController,
                          hint: 'example@gmail.com',
                          suffixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.email,
                        ),

                        SizedBox(height: 32.h(context)),

                        // ── Send OTP button ─────────────────────────────────
                        BlocBuilder<PasswordResetCubit, PasswordResetState>(
                          buildWhen: (prev, curr) =>
                              (prev is PasswordResetLoading) !=
                              (curr is PasswordResetLoading),
                          builder: (context, state) {
                            final isLoading = state is PasswordResetLoading;
                            return _PrimaryButton(
                              label: 'إرسال رمز التحقق',
                              icon: Icons.send_rounded,
                              isLoading: isLoading,
                              onPressed: _submit,
                            );
                          },
                        ),

                        SizedBox(height: 24.h(context)),

                        // ── Back to login link ───────────────────────────────
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              text: 'تذكرت كلمة المرور؟ ',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                              children: [
                                TextSpan(
                                  text: 'تسجيل الدخول',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.primaryForest,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
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

// ── Reusable sub-widgets ────────────────────────────────────────────────────

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
          // Text column
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
          // Accent bar + step badge
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
