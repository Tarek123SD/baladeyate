import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Banner shown while the map is in "add grave" tap mode.
class AddingModeBanner extends StatelessWidget {
  const AddingModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryGoldenWheat.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              const Icon(
                Icons.touch_app_rounded,
                color: AppColors.primaryDeepUmber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'اضغط على الخريطة لتحديد موقع القبر الجديد',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.primaryDeepUmber,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
