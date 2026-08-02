import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final isDelegate = user?.isDelegateLike ?? false;
        final name = user?.name ?? (isDelegate ? 'مندوب' : 'مواطن');
        final nationalId =
            user?.nationalId ?? user?.nationalNumber ?? 'غير متوفر';
        final statusLabel = isDelegate
            ? 'مندوب ميداني'
            : (user?.verificationStatusLabel ?? 'غير موثّق');
        final isApproved = isDelegate ? true : (user?.isVerified ?? false);

        return Container(
          padding: EdgeInsets.all(16.s(context)),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18.r(context)),
            border: Border.all(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryForest,
                            fontWeight: FontWeight.w700,
                            fontSize: 18.f(context),
                          ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'رقم الهوية: $nationalId',
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondaryCharcoal
                                .withValues(alpha: 0.8),
                            fontSize: 15.f(context),
                          ),
                    ),
                    if (user?.phoneNumber != null) ...[
                      SizedBox(height: 4.h(context)),
                      Text(
                        'الهاتف: ${user!.phoneNumber}',
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.8),
                              fontSize: 15.f(context),
                            ),
                      ),
                    ],
                    SizedBox(height: 10.h(context)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w(context),
                        vertical: 6.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? Colors.green
                            : AppColors.thirdGoldenWheat
                                .withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                      child: Text(
                        statusLabel,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryForest,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.f(context),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w(context)),
              CircleAvatar(
                radius: 30.s(context),
                backgroundColor:
                    AppColors.primaryForest.withValues(alpha: 0.12),
                child: Icon(
                  AppIcons.user,
                  size: 30.ic(context),
                  color: AppColors.primaryForest,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
