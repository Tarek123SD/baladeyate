import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_settings_option_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_account_actions.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_footer.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_header.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_logout_button.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_profile_card.dart';
import 'package:baladeyate/features/settings/presentation/components/settings_section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openResetPassword(BuildContext context) async {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthSuccess) return;

    await context.push(
      '/forgot-password?email=${Uri.encodeComponent(authState.user.email)}&fromSettings=1',
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is ProfilePhoneUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث رقم الهاتف')),
          );
        } else if (state is ProfileVerificationSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إرسال طلب توثيق الهوية')),
          );
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedOut) {
            context.go('/login');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(
              showSettings: false,
              showBackButton: true,
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Dimensions.contentMaxWidth.w(context),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16.h(context),
                      horizontalPadding,
                      24.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SettingsHeader(),
                        SizedBox(height: 20.h(context)),
                        const SettingsProfileCard(),
                        SizedBox(height: 12.h(context)),
                        const SettingsAccountActions(),
                        SizedBox(height: 24.h(context)),
                        const SettingsSectionTitle(title: 'الإعدادات العامة'),
                        SizedBox(height: 12.h(context)),
                        const CustomSettingsOptionCard(
                          title: 'تغيير اللغة',
                          subtitle: 'العربية',
                          leadingIcon: AppIcons.language,
                        ),
                        SizedBox(height: 10.h(context)),
                        CustomSettingsOptionCard(
                          title: 'تغيير كلمة المرور',
                          leadingIcon: AppIcons.lock,
                          onTap: () => _openResetPassword(context),
                        ),
                        SizedBox(height: 24.h(context)),
                        const SettingsSectionTitle(
                          title: 'القانونية والمعلومات',
                        ),
                        SizedBox(height: 12.h(context)),
                        const CustomSettingsOptionCard(
                          title: 'سياسة الخصوصية',
                          leadingIcon: AppIcons.privacy,
                        ),
                        SizedBox(height: 10.h(context)),
                        const CustomSettingsOptionCard(
                          title: 'الشروط والأحكام العامة',
                          leadingIcon: AppIcons.terms,
                        ),
                        SizedBox(height: 24.h(context)),
                        const SettingsLogoutButton(),
                        SizedBox(height: 16.h(context)),
                        const SettingsFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
