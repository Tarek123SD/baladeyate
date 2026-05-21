import 'package:baladeyate/config/validator/validator.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hint,
    required this.suffixIcon,
  });
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final radius = 12.r(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
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
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          hintTextDirection: TextDirection.rtl,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
            borderSide: const BorderSide(color: Colors.black, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radius),
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
        validator: Validator.required,
      ),
    );
  }
}
