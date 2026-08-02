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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'مبلغ مخصص (ل.س)',
          textAlign: TextAlign.right,
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
          textAlign: TextAlign.right,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'أدخل المبلغ بالليرة السورية',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13.5.f(context),
              fontWeight: FontWeight.normal,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 16.h(context),
            ),
            prefixIcon: Icon(
              Icons.payments_outlined,
              color: AppColors.primaryForest,
              size: 20.ic(context),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r(context)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r(context)),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r(context)),
              borderSide: const BorderSide(
                color: AppColors.primaryForest,
                width: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
