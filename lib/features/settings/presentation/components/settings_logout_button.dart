import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsLogoutButton extends StatelessWidget {
  const SettingsLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          height: 52.h(context),
          child: ElevatedButton.icon(
            onPressed:
                isLoading ? null : () => context.read<AuthCubit>().logout(),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.green,
              disabledBackgroundColor: AppColors.green.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r(context)),
              ),
            ),
            icon: isLoading
                ? SizedBox(
                    width: 20.s(context),
                    height: 20.s(context),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.contrastingProgress(AppColors.green),
                    ),
                  )
                : Icon(AppIcons.logout, size: 20.ic(context)),
            label: Text(
              'تسجيل الخروج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.f(context),
                  ),
            ),
          ),
        );
      },
    );
  }
}
