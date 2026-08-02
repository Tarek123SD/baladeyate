import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'الإعدادات',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryForest,
            fontWeight: FontWeight.w700,
            fontSize: 26.f(context),
          ),
    );
  }
}
