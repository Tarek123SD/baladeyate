import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
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
  bool _showPassword = false;

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
          context.go('/main');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_white.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: ResponsiveBody(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 60.h(context)),
                    Image.asset(
                      'assets/images/Syrian_logo_icon_gold.png',
                      width: 150.s(context),
                      height: 150.s(context),
                    ),
                    SizedBox(height: 40.h(context)),
                    Text(
                      'تطبيق المواطن',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      'الجمهورية العربية السورية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 50.h(context)),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Container(
                          width: 4.s(context),
                          height: 80.h(context),
                          color: AppColors.green,
                          margin: EdgeInsets.only(left: 16.s(context)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "تسجيل الدخول",
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
                                'يرجى إدخال البريد الاٍلكتروني وكلمة المرور',
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
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h(context)),
                    const CustomFormFieldLabel(label: ' البريد الاٍلكتروني '),
                    SizedBox(height: 8.h(context)),
                    _AuthTextField(
                      controller: _emailController,
                      hint: 'example@gmail.com',
                      suffixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.email,
                    ),
                    SizedBox(height: 24.h(context)),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'كلمة المرور',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.s(context),
                            color: Colors.black87,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'نسيت كلمة المرور؟',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h(context)),
                    _AuthPasswordField(
                      controller: _passwordController,
                      isVisible: _showPassword,
                      onToggle: () {
                        setState(() => _showPassword = !_showPassword);
                      },
                      validator: Validator.password,
                    ),
                    SizedBox(height: 32.h(context)),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 56.h(context),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 20.s(context),
                                      ),
                                      SizedBox(width: 12.s(context)),
                                      Text(
                                        "تسجيل الدخول",
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
                      onTap: () => context.go('/signup'),
                      child: RichText(
                        textDirection: TextDirection.rtl,
                        text: TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w400,
                                  ),
                          children: [
                            TextSpan(
                              text: 'سجل الآن',
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
                    Text(
                      'SOVEREIGN SECURE ACCESS V2.0',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[400],
                            fontSize: 10.s(context),
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                    SizedBox(height: 24.h(context)),
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
    final r = 12.r(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r(context),
            offset: Offset(0, 4.s(context)),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[400])
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.s(context),
            vertical: 16.s(context),
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class _AuthPasswordField extends StatelessWidget {
  const _AuthPasswordField({
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    required this.validator,
  });

  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    final r = 12.r(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.r(context),
            offset: Offset(0, 4.s(context)),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        obscureText: !isVisible,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(color: Colors.grey[600]),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.lock_open : Icons.lock,
              color: Colors.grey[400],
            ),
            onPressed: onToggle,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.s(context),
            vertical: 16.s(context),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
