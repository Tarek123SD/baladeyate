import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomTrackFilterButton extends StatelessWidget {
  const CustomTrackFilterButton({
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
        child: Container(
          height: 44.h(context),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryForest : Colors.white,
            borderRadius: BorderRadius.circular(22.r(context)),
            border: Border.all(
              color:
                  isSelected ? AppColors.primaryForest : const Color(0xFFE0E0E0),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primaryForest,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
