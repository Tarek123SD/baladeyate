import 'dart:io';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _authorityController = TextEditingController();
  final TextEditingController _jobNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  File? _identityImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _authorityController.dispose();
    _jobNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء الحساب بنجاح!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/main');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
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
                    SizedBox(height: 40.h(context)),
                    Image.asset(
                      'assets/images/Syrian_logo_icon_gold.png',
                      width: 120.s(context),
                      height: 120.s(context),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Title
                    Text(
                      'إنشاء حساب جديد',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryForest,
                              ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 8.h(context)),
                    // Subtitle
                    Text(
                      'الجهاز الرقمي للخدمات السيادية',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 32.h(context)),
                    // First Name Field
                    const CustomFormFieldLabel(label: 'الاسم الأول'),
                    SizedBox(height: 8.h(context)),
                    CustomTextfield(
                      controller: _firstNameController,
                      hint: 'مثال: يوسف',
                      suffixIcon: null,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Last Name Field
                    const CustomFormFieldLabel(label: 'الكنية'),
                    SizedBox(height: 8.h(context)),
                    CustomTextfield(
                      controller: _authorityController,
                      hint: 'مثال: الخطيب',
                      suffixIcon: null,
                    ),
                    SizedBox(height: 24.h(context)),
                    // National Number Field
                    const CustomFormFieldLabel(label: 'الرقم الوطني'),
                    SizedBox(height: 8.h(context)),
                    CustomTextfield(
                      controller: _jobNumberController,
                      hint: '00000000000',
                      suffixIcon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: Validator.nationalNumber,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Phone Number Field
                    const CustomFormFieldLabel(label: 'رقم الهاتف'),
                    SizedBox(height: 8.h(context)),
                    CustomTextfield(
                      controller: _phoneController,
                      hint: '+963 900 000 000',
                      suffixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: Validator.phoneNumber,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Email Field
                    const CustomFormFieldLabel(label: 'البريد الإلكتروني'),
                    SizedBox(height: 8.h(context)),
                    CustomTextfield(
                      controller: _emailController,
                      hint: 'example@email.com',
                      suffixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validator.email,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Personal ID Photo Upload
                    const CustomFormFieldLabel(label: 'صورة الهوية الشخصية'),
                    SizedBox(height: 8.h(context)),
                    _buildUploadField(),
                    SizedBox(height: 24.h(context)),
                    // Password Field
                    const CustomFormFieldLabel(label: 'كلمة السر'),
                    SizedBox(height: 8.h(context)),
                    _buildPasswordField(
                      controller: _passwordController,
                      isVisible: _showPassword,
                      onToggle: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      validator: Validator.signupPassword,
                    ),
                    SizedBox(height: 24.h(context)),
                    // Confirm Password Field
                    const CustomFormFieldLabel(label: 'تأكيد كلمة السر'),
                    SizedBox(height: 8.h(context)),
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreeToTerms = !_agreeToTerms;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بالخدمات',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          SizedBox(height: 8.h(context)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildTermsCheckbox(context),
                              Expanded(
                                child: Text(
                                  'الرقمية السيادية.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[700],
                                        height: 1.4,
                                      ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h(context)),
                    // Create Account Button
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 56.h(context),
                          child: ElevatedButton(
                            onPressed: (_agreeToTerms && !isLoading)
                                ? _handleCreateAccount
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              disabledBackgroundColor: Colors.grey[300],
                              elevation: (_agreeToTerms && !isLoading) ? 4 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(28.r(context)),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 24.s(context),
                                    height: 24.s(context),
                                    child: const CircularProgressIndicator(
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Row(
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
                        );
                      },
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    // Footer
                    Text(
                      'الجهاز الرقمي للخدمات السيادية',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[800],
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

  Widget _buildTermsCheckbox(BuildContext context) {
    final boxSize = 22.s(context);

    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r(context)),
        border: Border.all(
          color: AppColors.primaryForest,
          width: 1.5,
        ),
      ),
      child: _agreeToTerms
          ? Center(
              child: Icon(
                Icons.check,
                size: 16.s(context),
                color: AppColors.green,
              ),
            )
          : null,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
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
        validator: validator ??
            (value) => Validator.confirmPassword(
                  value,
                  _passwordController.text,
                ),
      ),
    );
  }

  Widget _buildUploadField() {
    final r = 12.r(context);
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h(context)),
        decoration: BoxDecoration(
          border: Border.all(
            color: _identityImage == null ? Colors.grey[300]! : AppColors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(r),
          color: _identityImage == null
              ? Colors.grey[50]
              : Colors.green.withValues(alpha: 0.05),
        ),
        child: _identityImage != null
            ? Column(
                children: [
                  Container(
                    width: 60.s(context),
                    height: 60.s(context),
                    decoration: const BoxDecoration(
                      color: Color(0xFF90EE90),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.primaryForest,
                      size: 32.s(context),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'تم تحميل الصورة بنجاح',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryForest,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    _identityImage!.path.split('/').last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Column(
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
                      color: AppColors.primaryForest,
                      size: 32.s(context),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'اضغط هنا لرفع صورة الهوية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryForest,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'PNG / JPG / JPEG',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryForest,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        setState(() {
          _identityImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  void _handleCreateAccount() {
    if (_identityImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة الهوية')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signup(
            firstName: _firstNameController.text.trim(),
            lastName: _authorityController.text.trim(),
            nationalNumber: _jobNumberController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            identityImage: _identityImage!,
          );
    }
  }
}
