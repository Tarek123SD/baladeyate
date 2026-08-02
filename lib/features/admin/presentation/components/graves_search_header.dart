import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class GravesSearchHeader extends StatelessWidget {
  const GravesSearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'البحث في المدافن',
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: AppColors.primaryForest,
            fontSize: 22.f(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 16.h(context)),
        TextField(
          controller: controller,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'ابحث برقم القبر أو القطعة أو الحالة',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r(context)),
              borderSide: BorderSide(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
