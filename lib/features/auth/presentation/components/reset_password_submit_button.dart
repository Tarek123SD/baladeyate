import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_cubit.dart';
import 'package:baladeyate/features/auth/cubits/password_reset_cubit/password_reset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ResetPasswordSubmitButton extends StatelessWidget {
  const ResetPasswordSubmitButton({
    super.key,
    required this.isSendingOtp,
    required this.onPressed,
  });

  final bool isSendingOtp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordResetCubit, PasswordResetState>(
      buildWhen: (previous, current) =>
          (previous is PasswordResetLoading) !=
          (current is PasswordResetLoading),
      builder: (context, state) {
        final isSubmitting = state is PasswordResetLoading && !isSendingOtp;

        return SizedBox(
          height: 56.h(context),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.secondaryForest,
              disabledBackgroundColor:
                  AppColors.secondaryForest.withValues(alpha: 0.6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r(context)),
              ),
            ),
            child: isSubmitting
                ? SizedBox(
                    width: 24.s(context),
                    height: 24.s(context),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 20.s(context),
                      ),
                      SizedBox(width: 10.w(context)),
                      Text(
                        'تأكيد كلمة المرور',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16.f(context),
                                ),
                      ),
                    ],
                  ),
          ),
        )
            .animate()
            .fadeIn(duration: 350.ms, delay: 240.ms)
            .slideY(begin: 0.08, end: 0);
      },
    );
  }
}
