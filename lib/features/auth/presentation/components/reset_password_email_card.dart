import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/widgets/custom_form_field_label.dart';
import 'package:baladeyate/core/widgets/custom_textfield.dart';
import 'package:baladeyate/features/auth/presentation/components/password_reset_section_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResetPasswordEmailCard extends StatelessWidget {
  const ResetPasswordEmailCard({
    super.key,
    required this.controller,
    required this.readOnly,
  });

  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return PasswordResetSectionCard(
      icon: Icons.email_outlined,
      title: 'البريد الإلكتروني',
      animateDelayMs: 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomFormFieldLabel(label: 'عنوان البريد'),
          SizedBox(height: 8.h(context)),
          AbsorbPointer(
            absorbing: readOnly,
            child: Opacity(
              opacity: readOnly ? 0.75 : 1,
              child: CustomTextfield(
                controller: controller,
                hint: 'example@gmail.com',
                suffixIcon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validator.email,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
