import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationAmountButton extends StatelessWidget {
  const CustomDonationAmountButton({
    super.key,
    required this.amount,
    required this.width,
    this.onTap,
  });

  final int amount;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r(context)),
          border: Border.all(
            color: AppColors.secondaryGoldenWheat,
            width: 1.4.w(context),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ",")} ل.س',
          style: TextStyle(
            color: AppColors.primaryForest,
            fontWeight: FontWeight.bold,
            fontSize: 14.f(context),
          ),
        ),
      ),
    );
  }
}
