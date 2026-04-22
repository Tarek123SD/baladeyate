import 'package:flutter/material.dart';
import '../utils/constants.dart';
import './login.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Header Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryForest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  'إنشاء حساب جديد',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryForest,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  'الجهاية الرقمية للخدمات السيادية',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 32),
                // First Name Field
                _buildLabel('الاسم الأول'),
                _buildTextField(
                  controller: _firstNameController,
                  hint: 'مثال: يوسف',
                  suffixIcon: null,
                ),
                const SizedBox(height: 24),
                // Authority Field
                _buildLabel('الكنية'),
                _buildTextField(
                  controller: _authorityController,
                  hint: 'مثال: الحطيب',
                  suffixIcon: null,
                ),
                const SizedBox(height: 24),
                // Job Number Field
                _buildLabel('الرقم الوطني'),
                _buildTextField(
                  controller: _jobNumberController,
                  hint: '00000000000',
                  suffixIcon: Icons.badge,
                ),
                const SizedBox(height: 24),
                // Phone Number Field
                _buildLabel('رقم الهاتف'),
                _buildTextField(
                  controller: _phoneController,
                  hint: '+963 900 000 000',
                  suffixIcon: Icons.phone,
                ),
                const SizedBox(height: 24),
                // Personal ID Photo Upload
                _buildLabel('صورة الهوية الشخصية'),
                _buildUploadField(),
                const SizedBox(height: 24),
                // Password Field
                _buildLabel('كلمة السر'),
                _buildPasswordField(
                  controller: _passwordController,
                  isVisible: _showPassword,
                  onToggle: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                const SizedBox(height: 24),
                // Confirm Password Field
                _buildLabel('تأكيد كلمة السر'),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  isVisible: _showConfirmPassword,
                  onToggle: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                const SizedBox(height: 20),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _agreeToTerms ? _handleCreateAccount : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.green,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: _agreeToTerms ? 4 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إنشاء الحساب',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign In Link
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LogIn()),
                    );
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppConstants.primaryForest,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Footer
                Text(
                  'SOVEREIGN SERVICES PORTAL · DIGITAL IDENTITY\nDIVISION',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.grey[400])
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.lock_open : Icons.lock,
              color: Colors.grey[400],
            ),
            onPressed: onToggle,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD699),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: AppConstants.primaryForest,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'احفظ هنا لرفع وثيقة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
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
