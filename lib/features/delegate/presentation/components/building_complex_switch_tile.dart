import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingComplexSwitchTile extends StatelessWidget {
  const BuildingComplexSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primaryForest,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13.s(context),
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryCharcoal,
        ),
      ),
    );
  }
}
