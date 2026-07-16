import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationAmountField extends StatelessWidget {
  const CustomDonationAmountField({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'مبلغ مخصص (ل.س)',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryForest,
            fontSize: 14.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h(context)),
        TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'أدخل القيمة يدوياً',
            hintStyle: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
              fontSize: 13.f(context),
              fontWeight: FontWeight.normal,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 18.h(context),
            ),
            prefixIcon: Icon(
              Icons.payments_rounded,
              color: AppColors.primaryGoldenWheat,
              size: 20.ic(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r(context)),
              borderSide: const BorderSide(
                color: AppColors.secondaryGoldenWheat,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r(context)),
              borderSide: const BorderSide(color: Color(0xFFD9D2C2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.r(context)),
              borderSide: const BorderSide(
                color: AppColors.green,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
