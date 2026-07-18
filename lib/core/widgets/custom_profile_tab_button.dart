import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomProfileTabButton extends StatelessWidget {
  const CustomProfileTabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44.h(context),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForest : Colors.transparent,
            borderRadius: BorderRadius.circular(22.r(context)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryForest,
              fontWeight: FontWeight.w600,
              fontSize: 12.f(context),
            ),
          ),
        ),
      ),
    );
  }
}
