import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Centered 6-digit OTP input used across password-reset screens.
class PasswordResetOtpField extends StatelessWidget {
  const PasswordResetOtpField({
    super.key,
    required this.controller,
    this.fontSize = 26,
    this.letterSpacing = 12,
    this.hintFontSize = 20,
    this.hintLetterSpacing = 8,
    this.verticalPadding = 20,
  });

  final TextEditingController controller;
  final double fontSize;
  final double letterSpacing;
  final double hintFontSize;
  final double hintLetterSpacing;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);
    OutlineInputBorder outline(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        validator: Validator.otp,
        cursorColor: AppColors.secondaryForest,
        style: TextStyle(
          color: Colors.black,
          fontSize: fontSize.f(context),
          fontWeight: FontWeight.w700,
          letterSpacing: letterSpacing,
        ),
        decoration: InputDecoration(
          hintText: '• • • • • •',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: hintFontSize.f(context),
            letterSpacing: hintLetterSpacing,
          ),
          filled: true,
          fillColor: AppColors.inputFill,
          counterText: '',
          prefixIcon: Icon(
            Icons.pin_outlined,
            color: AppColors.secondaryForest,
            size: 20.s(context),
          ),
          border: outline(AppColors.inputBorder, 1.4),
          enabledBorder: outline(AppColors.inputBorder, 1.4),
          focusedBorder: outline(AppColors.inputFocusedBorder, 1.8),
          errorBorder: outline(AppColors.alertRed, 1.4),
          focusedErrorBorder: outline(AppColors.alertRed, 1.8),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w(context),
            vertical: verticalPadding.h(context),
          ),
        ),
      ),
    );
  }
}
