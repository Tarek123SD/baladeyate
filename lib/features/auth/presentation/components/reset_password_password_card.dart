import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/password_input_field.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_section_card.dart';
import 'package:baladeyate/features/auth/presentation/components/password_strength_indicator.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResetPasswordPasswordCard extends StatelessWidget {
  const ResetPasswordPasswordCard({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.showPassword,
    required this.showConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool showPassword;
  final bool showConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  @override
  Widget build(BuildContext context) {
    return PasswordResetSectionCard(
      icon: Icons.shield_outlined,
      title: 'كلمة المرور الجديدة',
      animateDelayMs: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomFormFieldLabel(label: 'كلمة المرور'),
          SizedBox(height: 8.h(context)),
          PasswordInputField(
            controller: passwordController,
            isVisible: showPassword,
            onToggle: onTogglePassword,
            validator: Validator.password,
            hint: 'أدخل كلمة مرور قوية',
          ),
          if (passwordController.text.isNotEmpty) ...[
            SizedBox(height: 12.h(context)),
            PasswordStrengthIndicator(password: passwordController.text),
          ],
          SizedBox(height: 16.h(context)),
          const CustomFormFieldLabel(label: 'تأكيد كلمة المرور'),
          SizedBox(height: 8.h(context)),
          PasswordInputField(
            controller: confirmPasswordController,
            isVisible: showConfirmPassword,
            onToggle: onToggleConfirmPassword,
            validator: (value) {
              final passwordError = Validator.password(value);
              if (passwordError != null) return passwordError;
              if (value != passwordController.text) {
                return 'كلمتا المرور غير متطابقتين';
              }
              return null;
            },
            hint: 'أعد إدخال كلمة المرور',
          ),
        ],
      ),
    );
  }
}
