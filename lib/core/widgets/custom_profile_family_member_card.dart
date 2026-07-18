import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomProfileFamilyMemberCard extends StatelessWidget {
  const CustomProfileFamilyMemberCard({
    super.key,
    required this.name,
    required this.nationalId,
    required this.role,
    required this.initials,
    this.avatarColor,
  });

  final String name;
  final String nationalId;
  final String role;
  final String initials;
  final Color? avatarColor;

  static const _avatarPalette = [
    AppColors.primaryForest,
    AppColors.secondaryForest,
    AppColors.thirdForest,
    AppColors.primaryGoldenWheat,
  ];

  Color _resolveAvatarColor() {
    if (avatarColor != null) return avatarColor!;
    final hash = name.hashCode.abs();
    return _avatarPalette[hash % _avatarPalette.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _resolveAvatarColor();
    final isLightAvatar = bgColor == AppColors.primaryGoldenWheat;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.s(context)),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50.s(context),
            height: 50.s(context),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: isLightAvatar ? AppColors.primaryForest : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.f(context),
              ),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForest,
                      ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'الرقم الوطني: $nationalId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
                      ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w(context),
                    vertical: 4.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12.r(context)),
                  ),
                  child: Text(
                    role,
                    style: TextStyle(
                      fontSize: 11.f(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryForest,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
