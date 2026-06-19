import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_settings_option_card.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.isMobile ? 16.w(context) : 24.w(context);

    return BlocProvider(
      create: (_) => sl<ProfileCubit>(),
      child: BlocListener<ProfileCubit, ProfileState>(
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
                constraints: BoxConstraints(maxWidth: 760.w(context)),
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
                      _buildHeader(context),
                      SizedBox(height: 20.h(context)),
                      _buildProfileCard(context),
                      SizedBox(height: 12.h(context)),
                      _buildAccountActions(context),
                      SizedBox(height: 24.h(context)),
                      _buildSectionTitle(context, 'الإعدادات العامة'),
                      SizedBox(height: 12.h(context)),
                      const CustomSettingsOptionCard(
                        title: 'تغيير اللغة',
                        subtitle: 'العربية',
                        leadingIcon: Icons.language_rounded,
                      ),
                      SizedBox(height: 10.h(context)),
                      const CustomSettingsOptionCard(
                        title: 'تغيير كلمة المرور',
                        leadingIcon: Icons.lock_outline_rounded,
                      ),
                      SizedBox(height: 24.h(context)),
                      _buildSectionTitle(context, 'القانونية والمعلومات'),
                      SizedBox(height: 12.h(context)),
                      const CustomSettingsOptionCard(
                        title: 'سياسة الخصوصية',
                        leadingIcon: Icons.privacy_tip_outlined,
                      ),
                      SizedBox(height: 10.h(context)),
                      const CustomSettingsOptionCard(
                        title: 'الشروط والأحكام العامة',
                        leadingIcon: Icons.gavel_rounded,
                      ),
                      SizedBox(height: 24.h(context)),
                      _buildLogoutButton(context),
                      SizedBox(height: 16.h(context)),
                      _buildFooter(context),
                    ],
                  ),
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

  Widget _buildHeader(BuildContext context) {
    return Text(
      'الإعدادات',
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primaryForest,
            fontWeight: FontWeight.w700,
            fontSize: 26.f(context),
          ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final name = user?.name ?? 'مواطن';
        final nationalId =
            user?.nationalId ?? user?.nationalNumber ?? 'غير متوفر';
        final statusLabel =
            user?.verificationStatusLabel ?? 'غير موثّق';
        final isApproved = user?.isVerified ?? false;

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
                            fontSize: 13.f(context),
                          ),
                    ),
                    if (user?.phoneNumber != null) ...[
                      SizedBox(height: 4.h(context)),
                      Text(
                        'الهاتف: ${user!.phoneNumber}',
                        textDirection: TextDirection.rtl,
                        style: Theme.of(context).textTheme.bodySmall,
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
                            ? AppColors.thirdGoldenWheat
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
                  Icons.person,
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

  Widget _buildAccountActions(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;
        if (user == null) return const SizedBox.shrink();

        return Column(
          children: [
            CustomSettingsOptionCard(
              title: 'تحديث رقم الهاتف',
              subtitle: user.phoneNumber ?? 'إضافة رقم',
              leadingIcon: Icons.phone_outlined,
              onTap: () => _showPhoneDialog(context, user),
            ),
            if (user.canSubmitVerification) ...[
              SizedBox(height: 10.h(context)),
              CustomSettingsOptionCard(
                title: 'توثيق الهوية',
                subtitle: 'إرسال الهوية للمراجعة الحكومية',
                leadingIcon: Icons.verified_user_outlined,
                onTap: () => _showVerifyIdentityDialog(context, user),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showPhoneDialog(BuildContext context, User user) async {
    final controller = TextEditingController(text: user.phoneNumber ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تحديث رقم الهاتف'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'رقم الهاتف'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result == null || result.isEmpty || !context.mounted) return;
    await context.read<ProfileCubit>().updatePhone(result);
  }

  Future<void> _showVerifyIdentityDialog(BuildContext context, User user) async {
    final nationalIdController = TextEditingController(
      text: user.nationalId ?? user.nationalNumber ?? '',
    );
    File? imageFile;
    final picker = ImagePicker();

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('توثيق الهوية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nationalIdController,
                keyboardType: TextInputType.number,
                maxLength: 11,
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني (11 رقم)',
                ),
              ),
              SizedBox(height: 8.h(context)),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    setState(() => imageFile = File(picked.path));
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: Text(
                  imageFile == null ? 'اختيار صورة الهوية' : 'تم اختيار الصورة',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('إرسال'),
            ),
          ],
        ),
      ),
    );

    final nationalId = nationalIdController.text.trim();
    nationalIdController.dispose();

    if (submitted != true ||
        nationalId.length != 11 ||
        imageFile == null ||
        !context.mounted) {
      if (submitted == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى إدخال الرقم الوطني وصورة الهوية'),
          ),
        );
      }
      return;
    }

    await context.read<ProfileCubit>().verifyIdentity(
          nationalId: nationalId,
          identityImage: imageFile!,
        );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primaryForest,
            fontWeight: FontWeight.w700,
            fontSize: 17.f(context),
          ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SizedBox(
          height: 52.h(context),
          child: ElevatedButton.icon(
            onPressed: isLoading
                ? null
                : () => context.read<AuthCubit>().logout(),
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
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Icon(Icons.logout_rounded, size: 20.ic(context)),
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

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'V2.4.0 إصدار النظام',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                fontSize: 12.f(context),
              ),
        ),
        SizedBox(height: 4.h(context)),
        Text(
          'الدعم الفني الحكومي المركز',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.w600,
                fontSize: 12.f(context),
              ),
        ),
      ],
    );
  }
}
