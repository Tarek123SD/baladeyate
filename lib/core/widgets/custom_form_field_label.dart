import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomFormFieldLabel extends StatelessWidget {
  const CustomFormFieldLabel({
    super.key,
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.s(context),
          color: Colors.black87,
        ),
      ),
    );
  }
}
