import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationAmountField extends StatelessWidget {
  const CustomDonationAmountField({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'مبلغ مخصص (ل.س)',
          style: TextStyle(
            color: AppColors.primaryForest,
            fontSize: 14.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h(context)),
        TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 14.f(context)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'أدخل القيمة يدوياً',
            hintStyle: TextStyle(
              color: AppColors.secondaryCharcoal,
              fontSize: 13.f(context),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 18.h(context),
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
            suffixIcon: Icon(
              Icons.add,
              color: AppColors.primaryForest,
              size: 20.ic(context),
            ),
          ),
        ),
      ],
    );
  }
}
