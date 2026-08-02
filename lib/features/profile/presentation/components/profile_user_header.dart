import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileUserHeader extends StatelessWidget {
  const ProfileUserHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final String initials = user.name.trim().isNotEmpty
        ? user.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((s) => s.isNotEmpty ? s[0] : '')
            .join()
        : 'م';

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
        children: [
          CircleAvatar(
            radius: 46.r(context),
            backgroundColor: AppColors.primaryForest.withValues(alpha: 0.1),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 28.f(context),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 20.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h(context)),
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
