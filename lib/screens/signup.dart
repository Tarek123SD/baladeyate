import 'package:baladeyate/widgets/custom_textfield.dart';
import 'package:baladeyate/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import '../utils/constants.dart';

class SignUP extends StatefulWidget {
  const SignUP({super.key});

  @override
  State<SignUP> createState() => _SignUPState();
}

class _SignUPState extends State<SignUP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _authorityController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _authorityController.dispose();
    _jobNumberController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                  SizedBox(height: 40.h(context)),
                  // Header Image
                  Container(
                    width: 100.s(context),
                    height: 100.s(context),
                    decoration: BoxDecoration(
                      color: AppConstants.secondaryForest,
                      borderRadius: BorderRadius.circular(8.r(context)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        size: 60.s(context),
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h(context)),
                  // Title
                  Text(
                    'إنشاء حساب جديد',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryForest,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  // Subtitle
                  Text(
                    'الجهاية الرقمية للخدمات السيادية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 32.h(context)),
                  // First Name Field
                  _buildLabel(context, 'الاسم الأول'),
                  CustomTextfield(
                    controller: _firstNameController,
                    hint: 'مثال: يوسف',
                    suffixIcon: null,
                  ),
                  SizedBox(height: 24.h(context)),
                  // Authority Field
                  _buildLabel(context, 'الكنية'),
                  CustomTextfield(
                    controller: _authorityController,
                    hint: 'مثال: الحطيب',
                    suffixIcon: null,
                  ),
                  SizedBox(height: 24.h(context)),
                  // Job Number Field
                  _buildLabel(context, 'الرقم الوطني'),
                  CustomTextfield(
                    controller: _jobNumberController,
                    hint: '00000000000',
                    suffixIcon: Icons.badge,
                  ),
                  SizedBox(height: 24.h(context)),
                  // Phone Number Field
                  _buildLabel(context, 'رقم الهاتف'),
                  CustomTextfield(
                    controller: _phoneController,
                    hint: '+963 900 000 000',
                    suffixIcon: Icons.phone,
                  ),
                  SizedBox(height: 24.h(context)),
                  // Personal ID Photo Upload
                  _buildLabel(context, 'صورة الهوية الشخصية'),
                  _buildUploadField(),
                  SizedBox(height: 24.h(context)),
                  // Password Field
                  _buildLabel(context, 'كلمة السر'),
                  _buildPasswordField(
                    controller: _passwordController,
                    isVisible: _showPassword,
                    onToggle: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                  SizedBox(height: 24.h(context)),
                  // Confirm Password Field
                  _buildLabel(context, 'تأكيد كلمة السر'),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    isVisible: _showConfirmPassword,
                    onToggle: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                  SizedBox(height: 20.h(context)),
                  // Terms Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        activeColor: AppConstants.primaryForest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بالخدمات الرقمية السيادية.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h(context)),
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h(context),
                    child: ElevatedButton(
                      onPressed: _agreeToTerms ? _handleCreateAccount : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.green,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: _agreeToTerms ? 4 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r(context)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إنشاء الحساب',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.s(context),
                                ),
                          ),
                          SizedBox(width: 12.s(context)),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20.s(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h(context)),
                  // Sign In Link
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: RichText(
                      textDirection: TextDirection.rtl,
                      text: TextSpan(
                        text: 'لديك حساب بالفعل؟ ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    'SOVEREIGN SERVICES PORTAL · DIGITAL IDENTITY\nDIVISION',
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
            return 'كلمة السر مطلوبة';
          }
          if (value!.length < 8) {
            return 'يجب أن تكون كلمة السر 8 أحرف على الأقل';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUploadField() {
    final r = 12.r(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h(context)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(r),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Container(
            width: 60.s(context),
            height: 60.s(context),
            decoration: const BoxDecoration(
              color: Color(0xFFFFD699),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: AppConstants.primaryForest,
              size: 32.s(context),
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'احفظ هنا لرفع وثيقة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 8.h(context)),
          Text(
            'PNG JPG 5 محرفات',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  void _handleCreateAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
      );
    }
  }
}
