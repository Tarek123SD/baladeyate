import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
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

    final email = _emailController.text.trim();
    final success = await context.read<PasswordResetCubit>().sendOtp(email);
    if (!mounted || !success) return;

    context.push(
      '/reset-password?email=${Uri.encodeComponent(email)}',
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
                        Image.asset(
                          AppAssets.logoGold,
                          width: 150.s(context),
                          height: 150.s(context),
                        ),
                        SizedBox(height: 24.h(context)),
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
                        SizedBox(height: 8.h(context)),
                        Text(
                          'الجمهورية العربية السورية',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 50.h(context)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'استعادة كلمة المرور',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  SizedBox(height: 8.h(context)),
                                  Text(
                                    'أدخل بريدك الإلكتروني وسنرسل لك رمز تحقق مكوّن من 6 أرقام',
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                              SizedBox(width: 16.s(context)),
                              Container(
                                width: 4.s(context),
                                height: 80.h(context),
                                color: AppColors.green,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30.h(context)),
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
                          buildWhen: (previous, current) =>
                              (previous is PasswordResetLoading) !=
                              (current is PasswordResetLoading),
                          builder: (context, state) {
                            final isLoading = state is PasswordResetLoading;
                            return SizedBox(
                              width: double.infinity,
                              height: 56.h(context),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryForest,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(28.r(context)),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 20.s(context),
                                          ),
                                          SizedBox(width: 12.s(context)),
                                          Text(
                                            'إرسال رمز التحقق',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.s(context),
                                                ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24.h(context)),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: TextSpan(
                              text: 'تذكرت كلمة المرور؟ ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
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
                                        fontSize: 14.s(context),
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
