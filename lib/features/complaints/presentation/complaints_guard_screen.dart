import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/complaints/presentation/complaint_form_screen.dart';
import 'package:baladeyate/features/complaints/presentation/identity_verification_screen.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Routes users to the correct complaints experience based on KYC status.
class ComplaintsGuardScreen extends StatefulWidget {
  const ComplaintsGuardScreen({super.key});

  @override
  State<ComplaintsGuardScreen> createState() => _ComplaintsGuardScreenState();
}

class _ComplaintsGuardScreenState extends State<ComplaintsGuardScreen> {
  @override
  void initState() {
    super.initState();
    // Pick up a fresh verification status (e.g. an admin just approved it).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthCubit>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthSuccess) {
          final user = authState.user;
          final status = user.verificationStatus ?? 'unverified';
          if (status == 'approved') {
            context.go('/track');
            return;
          }
          context.go(homeRouteFor(user));
        } else {
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const _GuardLoadingView();
          }

          if (state is! AuthSuccess) {
            return _GuardMessageView(
              icon: Icons.lock_outline_rounded,
              iconColor: AppColors.secondaryCharcoal,
              message: 'يرجى تسجيل الدخول للوصول إلى نظام الشكاوى.',
              actionLabel: 'تسجيل الدخول',
              onAction: () => context.go('/login'),
            );
          }

          final user = state.user;
          final status = user.verificationStatus ?? 'unverified';

          switch (status) {
            case 'approved':
              return const ComplaintFormScreen();
            case 'pending':
              return const _VerificationPendingView();
            case 'rejected':
              return _VerificationRejectedView(user: user);
            case 'unverified':
            default:
              return IdentityVerificationScreen(
                promptText:
                    'الرجاء توثيق هويتك الوطنية لتتمكن من استخدام نظام الشكاوى.',
                initialNationalId: user.nationalId ?? user.nationalNumber,
              );
          }
        },
      ),
    );
  }
}

class _GuardLoadingView extends StatelessWidget {
  const _GuardLoadingView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _VerificationPendingView extends StatelessWidget {
  const _VerificationPendingView();

  @override
  Widget build(BuildContext context) {
    return _GuardMessageView(
      icon: Icons.hourglass_top_rounded,
      iconColor: Colors.amber.shade700,
      message:
          'بياناتك قيد المراجعة. ستتمكن من رفع الشكاوى فور اعتماد هويتك من الإدارة.',
      actionLabel: 'تحديث الحالة',
      actionIcon: Icons.refresh_rounded,
      onAction: () => context.read<AuthCubit>().refreshUser(),
    );
  }
}

class _VerificationRejectedView extends StatelessWidget {
  const _VerificationRejectedView({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous is ProfileLoaded &&
              current is ProfileLoaded &&
              previous.showResubmitForm != current.showResubmitForm ||
          previous is! ProfileLoaded && current is ProfileLoaded,
      builder: (context, state) {
        final showResubmitForm = context.read<ProfileCubit>().showResubmitForm;

        if (showResubmitForm) {
          return IdentityVerificationScreen(
            promptText: 'أعد رفع هويتك الوطنية لإتمام التوثيق.',
            preferCamera: true,
            initialNationalId: user.nationalId ?? user.nationalNumber,
          );
        }

        final rejectionReason = user.rejectionReason?.trim().isNotEmpty == true
            ? user.rejectionReason!.trim()
            : 'لم يتم تحديد السبب';

        return _GuardMessageView(
          icon: Icons.error_outline_rounded,
          iconColor: Colors.red.shade700,
          message: 'تم رفض التوثيق: $rejectionReason. يرجى إعادة رفع الهوية.',
          actionLabel: 'إعادة رفع الهوية بالكاميرا',
          actionIcon: Icons.camera_alt_outlined,
          onAction: () =>
              context.read<ProfileCubit>().setShowResubmitForm(true),
        );
      },
    );
  }
}

class _GuardMessageView extends StatelessWidget {
  const _GuardMessageView({
    required this.icon,
    required this.iconColor,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    final home = homeRouteFor(
                      (context.read<AuthCubit>().state as AuthSuccess).user,
                    );
                    context.go(home);
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryForest,
                  size: 20.ic(context),
                ),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Text(
                  'تقديم شكوى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 20.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 48.s(context)),
            ],
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.s(context)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 520.w(context)),
                child: Container(
                  padding: EdgeInsets.all(28.s(context)),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(20.r(context)),
                    border: Border.all(
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 72.s(context),
                        color: iconColor,
                      ),
                      SizedBox(height: 20.h(context)),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 16.f(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryCharcoal,
                          height: 1.7,
                        ),
                      ),
                      if (actionLabel != null && onAction != null) ...[
                        SizedBox(height: 28.h(context)),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h(context),
                          child: ElevatedButton.icon(
                            onPressed: onAction,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14.r(context)),
                              ),
                            ),
                            icon: Icon(
                              actionIcon ?? Icons.refresh_rounded,
                              size: 20.s(context),
                            ),
                            label: Text(
                              actionLabel!,
                              style: TextStyle(
                                fontSize: 15.f(context),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
