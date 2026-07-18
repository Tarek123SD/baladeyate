import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hint,
    required this.suffixIcon,
    this.validator,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );
    return DecoratedBox(
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
        keyboardType: keyboardType,
        cursorColor: AppColors.secondaryForest,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15.f(context),
          fontWeight: FontWeight.w500,
        ),
        scrollPadding: const EdgeInsets.only(bottom: 120),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[700]),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: AppColors.inputFill,
          border: outline(AppColors.inputBorder, 1.4),
          enabledBorder: outline(AppColors.inputBorder, 1.4),
          focusedBorder: outline(AppColors.inputFocusedBorder, 1.8),
          errorBorder: outline(AppColors.alertRed, 1.4),
          focusedErrorBorder: outline(AppColors.alertRed, 1.8),
          prefixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: AppColors.secondaryForest)
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18.s(context),
            vertical: 17.s(context),
          ),
        ),
        validator: validator ?? Validator.required,
      ),
    );
  }
}
