import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileVerificationCard extends StatelessWidget {
  const ProfileVerificationCard({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
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
        iconData = AppIcons.verified;
        title = 'الحساب موثّق بالكامل';
        subtitle =
            'تم توثيق هويتك الوطنية بنجاح. جميع خدمات البلدية والشكاوى مفعلة بالكامل لحسابك.';
        break;
      case 'pending':
        cardColor = const Color(0xFFFFF3E0);
        borderColor = const Color(0xFFFFE0B2);
        iconColor = const Color(0xFFE65100);
        iconData = AppIcons.statsPending;
        title = 'قيد المراجعة';
        subtitle =
            'طلب توثيق الهوية قيد المراجعة حالياً من قبل إدارة البلدية. سيتم إشعارك فور اكتمال التوثيق.';
        break;
      case 'rejected':
        cardColor = const Color(0xFFFFEBEE);
        borderColor = const Color(0xFFFFCDD2);
        iconColor = const Color(0xFFC62828);
        iconData = AppIcons.error;
        title = 'تم رفض طلب التوثيق';
        subtitle =
            'سبب الرفض: ${user.rejectionReason ?? "الرجاء التحقق من البيانات وصورة الهوية وإعادة المحاولة."}';
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
              padding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 10.h(context),
              ),
            ),
            icon: Icon(AppIcons.refresh, size: 18.s(context)),
            label: Text(
              'إعادة تقديم طلب التوثيق',
              style: TextStyle(
                fontSize: 14.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        break;
      case 'unverified':
      default:
        cardColor = const Color(0xFFECEFF1);
        borderColor = const Color(0xFFCFD8DC);
        iconColor = const Color(0xFF37474F);
        iconData = AppIcons.privacy;
        title = 'حسابك غير موثّق';
        subtitle =
            'يرجى توثيق هويتك الوطنية لتتمكن من تقديم البلاغات والشكاوى والاستفادة من خدمات البلدية كاملة.';
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
              padding: EdgeInsets.symmetric(
                horizontal: 20.w(context),
                vertical: 12.h(context),
              ),
            ),
            icon: Icon(AppIcons.verified, size: 18.s(context)),
            label: Text(
              'ابدأ توثيق الهوية الآن',
              style: TextStyle(
                fontSize: 14.f(context),
                fontWeight: FontWeight.bold,
              ),
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
}
