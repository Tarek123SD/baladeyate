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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: width,
        padding: EdgeInsets.symmetric(vertical: 16.h(context)),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.green, AppColors.secondaryForest],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(18.r(context)),
          border: Border.all(
            color: isSelected
                ? AppColors.green
                : AppColors.secondaryGoldenWheat,
            width: 1.4.w(context),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.green.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isSelected ? 14 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w(context)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16.ic(context),
                    color: Colors.white,
                  ),
                  SizedBox(width: 6.w(context)),
                ],
                Text(
                  '$_formatted ل.س',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primaryForest,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.f(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
