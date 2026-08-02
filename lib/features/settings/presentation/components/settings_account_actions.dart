import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/app_role.dart';
import 'package:baladeyate/core/widgets/custom_settings_option_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_phone_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsAccountActions extends StatelessWidget {
  const SettingsAccountActions({super.key});

  String _verificationSubtitle(User user) {
    switch (user.verificationStatus) {
      case 'pending':
        return 'طلبك قيد المراجعة — يمكنك إعادة الإرسال إذا تأخر القبول';
      case 'rejected':
        final reason = user.rejectionReason;
        return reason != null && reason.isNotEmpty
            ? 'تم رفض الطلب: $reason — أعد الإرسال'
            : 'تم رفض الطلب — أعد إرسال الهوية';
      default:
        return 'إرسال الهوية للمراجعة الحكومية';
    }
  }

  Future<void> _showPhoneDialog(BuildContext context, User user) async {
    final result = await showSettingsPhoneUpdateDialog(context, user);
    if (result == null || result.isEmpty || !context.mounted) return;
    await context.read<ProfileCubit>().updatePhone(result);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;
        if (user == null) return const SizedBox.shrink();

        return Column(
          children: [
            CustomSettingsOptionCard(
              title: 'تحديث رقم الهاتف',
              subtitle: user.phoneNumber ?? 'إضافة رقم',
              leadingIcon: AppIcons.phone,
              onTap: () => _showPhoneDialog(context, user),
            ),
            if (!user.isDelegateLike && !user.isVerified) ...[
              SizedBox(height: 10.h(context)),
              CustomSettingsOptionCard(
                title: user.verificationStatus == 'pending'
                    ? 'إعادة إرسال طلب التوثيق'
                    : 'توثيق الهوية',
                subtitle: _verificationSubtitle(user),
                leadingIcon: AppIcons.verified,
                onTap: () => context.push('/verify-identity'),
              ),
            ],
          ],
        );
      },
    );
  }
}
