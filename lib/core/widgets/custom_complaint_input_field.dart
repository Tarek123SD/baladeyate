import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintInputField extends StatelessWidget {
  const CustomComplaintInputField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    this.controller,
  });

  final String hint;
  final int maxLines;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 14.f(context), color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.f(context), color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14.s(context),
          vertical: 14.s(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r(context)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
