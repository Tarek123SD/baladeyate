import 'package:baladeyate/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:baladeyate/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _nationalIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      context.go('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  // Header with logo and text
                  // Container(
                  //   width: 100,
                  //   height: 100,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.1),
                  //         blurRadius: 12,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: const Center(
                  //     child: Text(
                  //       ':TEXT\nTEX',
                  //       textAlign: TextAlign.center,
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.bold,
                  //         color: AppConstants.primaryForest,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Image.asset(
                    'assets/images/Syrian_logo_icon_gold.png',
                    width: 150.s(context),
                    height: 150.s(context),
                  ),
                  SizedBox(height: 40.h(context)),
                  // Title
                  Text(
                    'تطبيق المواطن',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  // Subtitle
                  Text(
                    'الجمهورية العربية السورية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 50.h(context)),
                  // Login section with vertical line
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 4.s(context),
                        height: 80.h(context),
                        color: AppConstants.green,
                        margin: EdgeInsets.only(left: 16.s(context)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'تسجيل الدخول',
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
                              'يرجى إدخال بيانات الهوية الشخصية',
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
                  // National ID Field
                  _buildLabel(context, 'الرقم الوطني'),
                  _buildTextField(
                    controller: _nationalIdController,
                    hint: '000-000-000-000',
                    suffixIcon: Icons.person,
                  ),
                  SizedBox(height: 24.h(context)),
                  // Password Field with Remember Me
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
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: AppConstants.primaryForest,
                            ),
                            Text(
                              'نسيت كلمة المرور؟',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h(context)),
                  _buildPasswordField(
                    controller: _passwordController,
                    isVisible: _showPassword,
                    onToggle: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  SizedBox(height: 32.h(context)),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h(context),
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.secondaryForest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r(context)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20.s(context),
                          ),
                          SizedBox(width: 12.s(context)),
                          Text(
                            'تسجيل الدخول',
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
                  ),
                  SizedBox(height: 24.h(context)),
                  // Sign Up Link
                  GestureDetector(
                    onTap: () {
                      context.go('/signup');
                    },
                    child: RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        text: 'ليس لديك حساب؟ ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                  color: AppConstants.primaryForest,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.s(context),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h(context)),
                  // Footer
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
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.s(context),
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    IconData? suffixIcon,
  }) {
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
        decoration: InputDecoration(
          hintText: hint,
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
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'هذا الحقل مطلوب';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
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
        decoration: InputDecoration(
          hintText: '••••••••',
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
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'كلمة المرور مطلوبة';
          }
          if (value!.length < 8) {
            return 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';
          }
          return null;
        },
      ),
    );
  }
}
