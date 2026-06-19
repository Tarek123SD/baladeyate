import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable form input field with RTL support, label, and optional icon.
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
            borderRadius: BorderRadius.circular(12.r(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
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
            decoration: InputDecoration(
              hintText: hint,
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.s(context),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: BorderSide(
                  color: AppColors.primaryForest,
                  width: 2,
                ),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
                      size: 20.s(context),
                    )
                  : null,
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
                      size: 20.s(context),
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 14.h(context),
              ),
            ),
            style: TextStyle(
              fontSize: 14.s(context),
              color: AppColors.secondaryCharcoal,
            ),
          ),
        ),
      ],
    );
  }
}
