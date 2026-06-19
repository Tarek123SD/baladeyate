import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_donation_campaign_card.dart';
import 'package:baladeyate/core/widgets/custom_donation_statistic_card.dart';
import 'package:flutter/material.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationsScreen extends StatelessWidget {
  static const List<int> _amounts = [25000, 10000, 100000, 50000];

  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = context.isMobile ? 16.w(context) : 24.w(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 760.w(context)),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 18.h(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(28.r(context)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(24.s(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w(context),
                                vertical: 6.h(context),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGoldenWheat,
                                borderRadius:
                                    BorderRadius.circular(18.r(context)),
                              ),
                              child: Text(
                                'حملة مميزة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.f(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h(context)),
                          Text(
                            'إعادة إعمار المدارس التاريخية',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.f(context),
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 12.h(context)),
                          Text(
                            'ساهم في ترميم الصروح التعليمية التي تعيد بناء التاريخ وتضمن مستقبلاً مشرقاً لأجيالنا القادمة.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.thirdGoldenWheat,
                              fontSize: 14.f(context),
                              height: 1.7,
                            ),
                          ),
                          SizedBox(height: 22.h(context)),
                          SizedBox(
                            width: 160.w(context),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGoldenWheat,
                                foregroundColor: AppColors.primaryForest,
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.h(context),
                                  horizontal: 16.w(context),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30.r(context)),
                                ),
                              ),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 18.ic(context),
                              ),
                              label: Text(
                                'تصدق الآن',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.f(context),
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h(context)),
                    Wrap(
                      runSpacing: 16.h(context),
                      spacing: 16.w(context),
                      children: [
                        CustomDonationStatisticCard(
                          width: (MediaQuery.of(context).size.width -
                                  (horizontalPadding * 2) -
                                  16.w(context)) /
                              2,
                          value: '89K',
                          label: 'متبرع نشط',
                        ),
                        CustomDonationStatisticCard(
                          width: (MediaQuery.of(context).size.width -
                                  (horizontalPadding * 2) -
                                  16.w(context)) /
                              2,
                          value: '+145',
                          label: 'مشروع مدعوم',
                        ),
                        CustomDonationStatisticCard(
                          width: (MediaQuery.of(context).size.width -
                                  (horizontalPadding * 2) -
                                  16.w(context)) /
                              2,
                          value: '24/7',
                          label: 'خدمة كاملة',
                        ),
                        CustomDonationStatisticCard(
                          width: (MediaQuery.of(context).size.width -
                                  (horizontalPadding * 2) -
                                  16.w(context)) /
                              2,
                          value: '12',
                          label: 'محافظة مستفيدة',
                        ),
                      ],
                    ),
                    SizedBox(height: 28.h(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الحملات النشطة',
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'عرض الكل »',
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 14.f(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h(context)),
                    CustomDonationCampaignCard(
                      label: 'صحي',
                      title: 'دعم الرعاية الصحية',
                      subtitle:
                          'تأمين المستلزمات الطبية والأدوية الأساسية للمراكز الصحية في المناطق المحتاجة.',
                      progress: 0.75,
                      statusLabel: '75% تم جمعه',
                      icon: Icons.local_hospital,
                      iconColor: AppColors.secondaryForest,
                    ),
                    SizedBox(height: 16.h(context)),
                    CustomDonationCampaignCard(
                      label: 'إغاثي',
                      title: 'السلة الغذائية',
                      subtitle:
                          'توزيع سلال غذائية متكاملة للأسر المحتاجة خلال الشهر المبارك.',
                      progress: 0.4,
                      statusLabel: '40% تم جمعه',
                      icon: Icons.food_bank,
                      iconColor: AppColors.primaryGoldenWheat,
                    ),
                    SizedBox(height: 28.h(context)),
                    Text(
                      'حدد قيمة التبرع',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 18.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h(context)),
                    Text(
                      'اختر المبلغ الذي ترغب في المساعدة به',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: AppColors.secondaryCharcoal,
                        fontSize: 13.f(context),
                      ),
                    ),
                    SizedBox(height: 18.h(context)),
                    Wrap(
                      spacing: 12.w(context),
                      runSpacing: 12.h(context),
                      children: _amounts.map((amount) {
                        final buttonWidth =
                            (MediaQuery.of(context).size.width -
                                    (horizontalPadding * 2) -
                                    12.w(context)) /
                                2;
                        return CustomDonationAmountButton(
                          amount: amount,
                          width: buttonWidth,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 18.h(context)),
                    const CustomDonationAmountField(),
                    SizedBox(height: 24.h(context)),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h(context),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r(context)),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'تأكيد التبرع والمتابعة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

