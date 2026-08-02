import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'إصدار النظام: V1.0.0',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.90),
                fontSize: 14.f(context),
              ),
        ),
        SizedBox(height: 4.h(context)),
      ],
    );
  }
}
