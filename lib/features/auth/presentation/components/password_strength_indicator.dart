import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Password strength meter with shared scoring helpers.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  static double strengthOf(String password) {
    if (password.isEmpty) return 0;
    var score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.length >= 12) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.15;
    return score.clamp(0, 1);
  }

  static String labelOf(double strength) {
    if (strength < 0.35) return 'ضعيفة';
    if (strength < 0.7) return 'متوسطة';
    return 'قوية';
  }

  static Color colorOf(double strength) {
    if (strength < 0.35) return AppColors.alertRed;
    if (strength < 0.7) return AppColors.primaryGoldenWheat;
    return AppColors.green;
  }

  @override
  Widget build(BuildContext context) {
    final strength = strengthOf(password);
    final color = colorOf(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6.r(context)),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 6.h(context),
            backgroundColor: AppColors.inputBorder,
            color: color,
          ),
        ),
        SizedBox(height: 6.h(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'قوة كلمة المرور',
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                fontSize: 12.f(context),
              ),
            ),
            Text(
              labelOf(strength),
              style: TextStyle(
                color: color,
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
