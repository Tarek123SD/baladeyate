import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, profileState) {
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: Dimensions.contentMaxWidth.w(context),
                    ),
                    child: RefreshIndicator(
                      color: AppColors.primaryForest,
                      onRefresh: () =>
                          context.read<ProfileCubit>().loadProfile(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          16.h(context),
                          horizontalPadding,
                          30.h(context),
                        ),
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, authState) {
                            if (authState is! AuthSuccess) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 80),
                                  child: Text('الرجاء تسجيل الدخول أولاً'),
                                ),
                              );
                            }

                            final user = authState.user;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Avatar and general info
                                _buildUserHeader(context, user)
                                    .animate()
                                    .fadeIn(duration: 350.ms)
                                    .slideY(begin: -0.1, end: 0),
                                SizedBox(height: 24.h(context)),

                                // KYC Identity Verification Status Card
                                _buildVerificationCard(context, user)
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 100.ms)
                                    .slideY(begin: 0.08, end: 0),
                                SizedBox(height: 24.h(context)),

                                // Core personal details
                                _buildPersonalDetailsSection(context, user)
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 200.ms)
                                    .slideY(begin: 0.08, end: 0),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserHeader(BuildContext context, User user) {
    // Get user initials (first letter of first and last name if possible)
    final String initials = user.name.trim().isNotEmpty
        ? user.name.trim().split(RegExp(r'\s+')).take(2).map((s) => s.isNotEmpty ? s[0] : '').join()
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

  Widget _buildVerificationCard(BuildContext context, User user) {
    final status = user.verificationStatus ?? 'unverified';
    
    Color cardColor;
    Color borderColor;
    Color iconColor;
    IconData iconData;
    String title;
    String subtitle;
    Widget? actionWidget;

    switch (status) {
      case 'approved':
        cardColor = const Color(0xFFE8F5E9);
        borderColor = const Color(0xFFC8E6C9);
        iconColor = const Color(0xFF2E7D32);
        iconData = Icons.verified_user_rounded;
        title = 'الحساب موثّق بالكامل';
        subtitle = 'تم توثيق هويتك الوطنية بنجاح. جميع خدمات البلدية والشكاوى مفعلة بالكامل لحسابك.';
        break;
      case 'pending':
        cardColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFE0B2);
        iconColor = const Color(0xFFE65100);
        iconData = Icons.pending_actions_rounded;
        title = 'قيد المراجعة';
        subtitle = 'طلب توثيق الهوية قيد المراجعة حالياً من قبل إدارة البلدية. سيتم إشعارك فور اكتمال التوثيق.';
        break;
      case 'rejected':
        cardColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFFCDD2);
        iconColor = const Color(0xFFC62828);
        iconData = Icons.gpp_bad_rounded;
        title = 'تم رفض طلب التوثيق';
        subtitle = 'سبب الرفض: ${user.rejectionReason ?? "الرجاء التحقق من البيانات وصورة الهوية وإعادة المحاولة."}';
        actionWidget = Padding(
          padding: EdgeInsets.only(top: 12.h(context)),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/verify-identity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w(context), vertical: 10.h(context)),
            ),
            icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
            label: Text(
              'إعادة تقديم طلب التوثيق',
              style: TextStyle(fontSize: 14.f(context), fontWeight: FontWeight.bold),
            ),
          ),
        );
        break;
      case 'unverified':
      default:
        cardColor = const Color(0xFFECEFF1);
        borderColor = const Color(0xFFCFD8DC);
        iconColor = const Color(0xFF37474F);
        iconData = Icons.shield_outlined;
        title = 'حسابك غير موثّق';
        subtitle = 'يرجى توثيق هويتك الوطنية لتتمكن من تقديم البلاغات والشكاوى والاستفادة من خدمات البلدية كاملة.';
        actionWidget = Padding(
          padding: EdgeInsets.only(top: 12.h(context)),
          child: ElevatedButton.icon(
            onPressed: () => context.push('/verify-identity'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w(context), vertical: 12.h(context)),
            ),
            icon: Icon(Icons.verified_user_outlined, size: 18.s(context)),
            label: Text(
              'ابدأ توثيق الهوية الآن',
              style: TextStyle(fontSize: 14.f(context), fontWeight: FontWeight.bold),
            ),
          ),
        );
        break;
    }

    return Container(
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 28.ic(context),
              ),
              SizedBox(width: 12.w(context)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h(context)),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.f(context),
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.85),
              height: 1.5,
            ),
            textDirection: TextDirection.rtl,
          ),
          if (actionWidget != null) actionWidget,
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection(BuildContext context, User user) {
    final nationalId = user.nationalId ?? user.nationalNumber ?? 'غير متوفر';
    final phoneNumber = user.phoneNumber ?? 'غير متوفر';

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
            'بيانات الحساب الأساسية',
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 16.h(context)),
          _buildDetailItem(
            context,
            icon: Icons.badge_outlined,
            label: 'رقم الهوية الوطنية',
            value: nationalId,
          ),
          const Divider(height: 24, thickness: 0.8),
          _buildDetailItem(
            context,
            icon: Icons.phone_android_rounded,
            label: 'رقم الهاتف',
            value: phoneNumber,
          ),
          const Divider(height: 24, thickness: 0.8),
          _buildDetailItem(
            context,
            icon: Icons.alternate_email_rounded,
            label: 'البريد الإلكتروني',
            value: user.email,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          padding: EdgeInsets.all(10.s(context)),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryForest,
            size: 20.ic(context),
          ),
        ),
        SizedBox(width: 14.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.f(context),
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 4.h(context)),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15.f(context),
                  color: AppColors.primaryForest,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
