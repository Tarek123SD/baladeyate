import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfilePersonalDetailsSection extends StatelessWidget {
  const ProfilePersonalDetailsSection({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final nationalId = user.nationalId ?? user.nationalNumber ?? 'غير متوفر';
    final phoneNumber = user.phoneNumber ?? 'غير متوفر';

    return Container(
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'بيانات الحساب الأساسية',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 16.h(context)),
          ProfileDetailItem(
            icon: AppIcons.personalCard,
            label: 'رقم الهوية الوطنية',
            value: nationalId,
          ),
          const Divider(height: 24, thickness: 0.8),
          ProfileDetailItem(
            icon: AppIcons.phone,
            label: 'رقم الهاتف',
            value: phoneNumber,
            valueTextDirection: TextDirection.ltr,
          ),
          const Divider(height: 24, thickness: 0.8),
          ProfileDetailItem(
            icon: AppIcons.email,
            label: 'البريد الإلكتروني',
            value: user.email,
          ),
        ],
      ),
    );
  }
}

class ProfileDetailItem extends StatelessWidget {
  const ProfileDetailItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueTextDirection = TextDirection.rtl,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextDirection valueTextDirection;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          padding: EdgeInsets.all(10.s(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryForest,
            size: 20.ic(context),
          ),
        ),
        SizedBox(width: 14.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.f(context),
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 4.h(context)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.f(context),
                  color: AppColors.primaryForest,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: valueTextDirection,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
