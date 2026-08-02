import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/password_input_field.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_state.dart';
import 'package:baladeyate/features/auth/presentation/components/auth_screen_widgets.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      context.read<AuthCubit>().login(email, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(homeRouteFor(state.user));
        } else if (state is AuthFailure) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: AuthScreenScaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBrandedHeader(
              title: 'بلديتي',
              subtitle: 'الجمهورية العربية السورية',
              tagline: 'المنصة المحلية لخدمات المواطنة',
            ),
            Expanded(
              child: SingleChildScrollView(
                child: AuthFormPanel(
                  child: ResponsiveBody(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        16.h(context),
                        0,
                        32.h(context),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthSectionHeader(
                              title: 'تسجيل الدخول',
                              subtitle:
                                  'يرجى إدخال البريد الاٍلكتروني وكلمة المرور',
                            ),
                            SizedBox(height: 32.h(context)),
                            const CustomFormFieldLabel(
                              label: ' البريد الاٍلكتروني ',
                            ),
                            SizedBox(height: 8.h(context)),
                            _AuthTextField(
                              controller: _emailController,
                              hint: 'example@gmail.com',
                              suffixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validator.email,
                            ),
                            SizedBox(height: 24.h(context)),
                            AuthPasswordLabelRow(
                              label: 'كلمة المرور',
                              forgotPasswordOnTap: () =>
                                  context.push('/forgot-password'),
                            ),
                            SizedBox(height: 8.h(context)),
                            BlocBuilder<AuthFormCubit, AuthFormState>(
                              buildWhen: (previous, current) =>
                                  previous.showPassword !=
                                  current.showPassword,
                              builder: (context, formState) {
                                return PasswordInputField(
                                  controller: _passwordController,
                                  isVisible: formState.showPassword,
                                  onToggle: () => context
                                      .read<AuthFormCubit>()
                                      .toggleShowPassword(),
                                  validator: Validator.password,
                                );
                              },
                            ),
                            SizedBox(height: 36.h(context)),
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return AuthPrimaryButton(
                                  label: 'تسجيل الدخول',
                                  leadingIcon: Icons.arrow_back,
                                  isLoading: isLoading,
                                  onPressed: _handleLogin,
                                );
                              },
                            ),
                            SizedBox(height: 24.h(context)),
                            AuthSwitchLink(
                              prompt: 'ليس لديك حساب؟ ',
                              actionLabel: 'سجل الآن',
                              onTap: () => context.go('/signup'),
                            ),
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
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.hint,
    this.suffixIcon,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final r = 14.r(context);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(r),
          borderSide: BorderSide(color: color, width: width),
        );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10.r(context),
            offset: Offset(0, 3.s(context)),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        cursorColor: AppColors.secondaryForest,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.f(context),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500]),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: AppColors.inputFill,
          border: outline(AppColors.inputBorder, 1.4),
          enabledBorder: outline(AppColors.inputBorder, 1.4),
          focusedBorder: outline(AppColors.inputFocusedBorder, 1.8),
          errorBorder: outline(AppColors.alertRed, 1.4),
          focusedErrorBorder: outline(AppColors.alertRed, 1.8),
          prefixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.secondaryForest)
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.s(context),
            vertical: 17.s(context),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
