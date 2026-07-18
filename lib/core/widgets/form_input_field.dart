import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable form input field with RTL support, label, and optional icon.
/// Styled to match the auth screen text fields for consistent visible input text.
class FormInputField extends StatelessWidget {
  const FormInputField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.obscureText = false,
    this.maxLines = 1,
  });

  /// Field label (displayed above the input)
  final String label;

  /// Placeholder hint text
  final String hint;

  /// Text controller
  final TextEditingController? controller;

  /// Icon displayed on the left (RTL) of the input
  final IconData? prefixIcon;

  /// Icon displayed on the right (RTL) of the input
  final IconData? suffixIcon;

  /// Whether the field is enabled
  final bool enabled;

  /// Whether the field is read-only
  final bool readOnly;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Validator function
  final String? Function(String?)? validator;

  /// On change callback
  final Function(String)? onChanged;

  /// Whether to obscure text (password)
  final bool obscureText;

  /// Max lines for input
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.s(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
          ),
        ),
        SizedBox(height: 10.h(context)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            textDirection: TextDirection.rtl,
            enabled: enabled,
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            cursorColor: AppColors.secondaryForest,
            style: TextStyle(
              fontSize: 14.f(context),
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: 13.f(context),
              ),
              filled: true,
              fillColor: enabled
                  ? AppColors.inputFill
                  : AppColors.inputFill.withValues(alpha: 0.6),
              border: outline(AppColors.inputBorder, 1.4),
              enabledBorder: outline(AppColors.inputBorder, 1.4),
              focusedBorder: outline(AppColors.inputFocusedBorder, 1.8),
              errorBorder: outline(AppColors.alertRed, 1.4),
              focusedErrorBorder: outline(AppColors.alertRed, 1.8),
              disabledBorder: outline(Colors.grey.shade300, 1.4),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.secondaryForest,
                      size: 20.s(context),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: AppColors.secondaryForest,
                      size: 20.s(context),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 15.h(context),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
