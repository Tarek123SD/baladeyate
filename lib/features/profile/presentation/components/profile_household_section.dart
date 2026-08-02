import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/delegate/models/registered_household.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_personal_details_section.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileHouseholdSection extends StatelessWidget {
  const ProfileHouseholdSection({
    super.key,
    this.household,
    this.message,
  });

  final RegisteredHousehold? household;
  final String? message;

  @override
  Widget build(BuildContext context) {
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
            'السجل السكني',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 16.h(context)),
          if (household != null) ...[
            ProfileDetailItem(
              icon: AppIcons.location,
              label: 'العنوان',
              value: household!.address.isEmpty ? 'غير متوفر' : household!.address,
            ),
            if (household!.electricityMeterNumber != null &&
                household!.electricityMeterNumber!.isNotEmpty) ...[
              const Divider(height: 24, thickness: 0.8),
              ProfileDetailItem(
                icon: AppIcons.housing,
                label: 'عداد الكهرباء',
                value: household!.electricityMeterNumber!,
              ),
            ],
            if (household!.waterMeterNumber != null &&
                household!.waterMeterNumber!.isNotEmpty) ...[
              const Divider(height: 24, thickness: 0.8),
              ProfileDetailItem(
                icon: AppIcons.housing,
                label: 'عداد المياه',
                value: household!.waterMeterNumber!,
              ),
            ],
            if (household!.members.isNotEmpty) ...[
              const Divider(height: 24, thickness: 0.8),
              Text(
                'أفراد الأسرة (${household!.members.length})',
                style: TextStyle(
                  fontSize: 12.f(context),
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 8.h(context)),
              ...household!.members.map(
                (member) => Padding(
                  padding: EdgeInsets.only(bottom: 6.h(context)),
                  child: Text(
                    '• ${member.fullName}',
                    style: TextStyle(
                      fontSize: 14.f(context),
                      color: AppColors.primaryForest,
                      fontWeight: FontWeight.w600,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ] else
            Text(
              message ?? 'لا يوجد سجل سكني مرتبط بحسابك بعد.',
              style: TextStyle(
                fontSize: 13.f(context),
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
            ),
        ],
      ),
    );
  }
}
