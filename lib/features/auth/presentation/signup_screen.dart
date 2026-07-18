import 'dart:io';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/core/widgets/password_input_field.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_form_cubit/auth_form_state.dart';
import 'package:baladeyate/features/auth/presentation/widgets/auth_screen_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/routes/auth_navigation.dart';

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
      listener: (context, state) async {
        if (state is AuthSuccess) {
          final cacheService = sl<CacheService>();
          final noticeShown = cacheService.getData(
                key: StorageKeys.signupVerificationNoticeShown,
              ) ==
              'true';

          if (!noticeShown) {
            await cacheService.saveData(
              key: StorageKeys.pendingSignupVerificationNotice,
              value: 'true',
            );
          }

          if (context.mounted) {
            context.go(homeRouteFor(state.user));
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: AuthScreenScaffold(
        showBackButton: true,
        onBack: () => context.go('/login'),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthBrandedHeader(
                compact: true,
                title: 'إنشاء حساب جديد',
                subtitle: 'المنصة المحلية لخدمات المواطنة',
              ),
              AuthFormPanel(
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
                            title: 'بيانات الحساب',
                            subtitle:
                                'أدخل بياناتك الشخصية لإتمام التسجيل',
                          ),
                          SizedBox(height: 28.h(context)),
                        const CustomFormFieldLabel(label: 'الاسم الأول'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _firstNameController,
                          hint: 'مثال: يوسف',
                          suffixIcon: null,
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'الكنية'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _authorityController,
                          hint: 'مثال: الخطيب',
                          suffixIcon: null,
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'الرقم الوطني'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _jobNumberController,
                          hint: '00000000000',
                          suffixIcon: Icons.badge,
                          keyboardType: TextInputType.number,
                          validator: Validator.nationalNumber,
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'رقم الهاتف'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _phoneController,
                          hint: '+963 900 000 000',
                          suffixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: Validator.phoneNumber,
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'البريد الإلكتروني'),
                        SizedBox(height: 8.h(context)),
                        CustomTextfield(
                          controller: _emailController,
                          hint: 'example@email.com',
                          suffixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validator.email,
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'صورة الهوية الشخصية'),
                        SizedBox(height: 8.h(context)),
                        BlocBuilder<AuthFormCubit, AuthFormState>(
                          buildWhen: (previous, current) =>
                              previous.identityImage != current.identityImage,
                          builder: (context, formState) =>
                              _buildUploadField(formState.identityImage),
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'كلمة السر'),
                        SizedBox(height: 8.h(context)),
                        BlocBuilder<AuthFormCubit, AuthFormState>(
                          buildWhen: (previous, current) =>
                              previous.showPassword != current.showPassword,
                          builder: (context, formState) => PasswordInputField(
                            controller: _passwordController,
                            isVisible: formState.showPassword,
                            onToggle: () => context
                                .read<AuthFormCubit>()
                                .toggleShowPassword(),
                            validator: Validator.signupPassword,
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        const CustomFormFieldLabel(label: 'تأكيد كلمة السر'),
                        SizedBox(height: 8.h(context)),
                        BlocBuilder<AuthFormCubit, AuthFormState>(
                          buildWhen: (previous, current) =>
                              previous.showConfirmPassword !=
                              current.showConfirmPassword,
                          builder: (context, formState) => PasswordInputField(
                            controller: _confirmPasswordController,
                            isVisible: formState.showConfirmPassword,
                            onToggle: () => context
                                .read<AuthFormCubit>()
                                .toggleShowConfirmPassword(),
                            validator: (value) => Validator.confirmPassword(
                              value,
                              _passwordController.text,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h(context)),
                        BlocBuilder<AuthFormCubit, AuthFormState>(
                          buildWhen: (previous, current) =>
                              previous.agreeToTerms != current.agreeToTerms,
                          builder: (context, formState) => _buildTermsSection(
                            context,
                            formState.agreeToTerms,
                          ),
                        ),
                        SizedBox(height: 28.h(context)),
                        BlocBuilder<AuthFormCubit, AuthFormState>(
                          buildWhen: (previous, current) =>
                              previous.agreeToTerms != current.agreeToTerms,
                          builder: (context, formState) {
                            return BlocBuilder<AuthCubit, AuthState>(
                              buildWhen: (previous, current) =>
                                  (previous is AuthLoading) !=
                                  (current is AuthLoading),
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return AuthPrimaryButton(
                                  label: 'إنشاء الحساب',
                                  trailingIcon: Icons.arrow_forward,
                                  backgroundColor: AppColors.green,
                                  isLoading: isLoading,
                                  enabled: formState.agreeToTerms,
                                  onPressed: _handleCreateAccount,
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: 20.h(context)),
                          AuthSwitchLink(
                            prompt: 'لديك حساب بالفعل؟ ',
                            actionLabel: 'تسجيل الدخول',
                            onTap: () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context, bool agreeToTerms) {
    return GestureDetector(
      onTap: () =>
          context.read<AuthFormCubit>().setAgreeToTerms(!agreeToTerms),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أوافق على شروط الاستخدام وسياسة الخصوصية الخاصة بالخدمات',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 8.h(context)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              _buildTermsCheckbox(context, agreeToTerms),
              Expanded(
                child: Text(
                  'الرقمية السيادية.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
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
    );
  }

  Widget _buildTermsCheckbox(BuildContext context, bool agreeToTerms) {
    final boxSize = 22.s(context);

    return Container(
      width: boxSize,
      height: boxSize,
      margin: EdgeInsets.only(left: 10.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r(context)),
        border: Border.all(
          color: AppColors.primaryForest,
          width: 1.5,
        ),
      ),
      child: agreeToTerms
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

  Widget _buildUploadField(File? identityImage) {
    final r = 12.r(context);

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h(context)),
        decoration: BoxDecoration(
          border: Border.all(
            color: identityImage == null ? Colors.grey[300]! : AppColors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(r),
          color: identityImage == null
              ? Colors.grey[50]
              : Colors.green.withValues(alpha: 0.05),
        ),
        child: identityImage != null
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
                    identityImage.path.split('/').last,
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
        imageQuality: 70,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        context.read<AuthFormCubit>().setIdentityImage(File(pickedFile.path));
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
    final identityImage = context.read<AuthFormCubit>().state.identityImage;
    if (identityImage == null) {
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
            identityImage: identityImage,
          );
    }
  }
}
