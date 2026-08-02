import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDonationAmountButton extends StatelessWidget {
  const CustomDonationAmountButton({
    super.key,
    required this.amount,
    required this.width,
    this.onTap,
    this.isSelected = false,
  });

  final int amount;
  final double width;
  final VoidCallback? onTap;
  final bool isSelected;

  String get _formatted =>
      amount.toString().replaceAllMapped(
            RegExp(r"\B(?=(\d{3})+(?!\d))"),
            (match) => ",",
          );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r(context)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeInOut,
          width: width,
          padding: EdgeInsets.symmetric(vertical: 14.h(context)),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForest : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14.r(context)),
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
              child: Text(
                '$_formatted ل.س',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF424242),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14.f(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
