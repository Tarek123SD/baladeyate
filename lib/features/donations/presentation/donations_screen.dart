import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_donation_campaign_card.dart';
import 'package:baladeyate/core/widgets/custom_donation_statistic_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationsScreen extends StatelessWidget {
  static const List<int> _amounts = [25000, 10000, 100000, 50000];

  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final maxContentWidth = ResponsiveHelper.contentMaxWidth(context);
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final contentContainerWidth =
        viewportWidth < maxContentWidth ? viewportWidth : maxContentWidth;
    final gridContentWidth = contentContainerWidth - (horizontalPadding * 2);
    final amountColumns = _gridColumns(context, mobile: 2);
    final amountWidth = _gridItemWidth(
      gridContentWidth,
      amountColumns,
      12,
      context,
    );

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 18.h(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFeaturedCampaignCard(context),
                      SizedBox(height: 28.h(context)),
                      _buildStatsGrid(context),
                      SizedBox(height: 28.h(context)),
                      const _SectionHeader(
                        title: 'الحملات النشطة',
                        actionLabel: 'عرض الكل »',
                      ),
                      SizedBox(height: 18.h(context)),
                      const CustomDonationCampaignCard(
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
                      const CustomDonationCampaignCard(
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
                        children: _amounts
                            .map(
                              (amount) => CustomDonationAmountButton(
                                amount: amount,
                                width: amountWidth,
                              ),
                            )
                            .toList(),
                      ),
                      SizedBox(height: 18.h(context)),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 420.w(context),
                          ),
                          child: const CustomDonationAmountField(),
                        ),
                      ),
                      SizedBox(height: 24.h(context)),
                      SizedBox(
                        width: double.infinity,
                        height: 56.h(context),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16.r(context)),
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
      ),
    );
  }

  static Widget _buildStatsGrid(BuildContext context) {
    const stats = <({String value, String label})>[
      (value: '89K', label: 'متبرع نشط'),
      (value: '+145', label: 'مشروع مدعوم'),
      (value: '24/7', label: 'خدمة كاملة'),
      (value: '12', label: 'محافظة مستفيدة'),
    ];

    final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
    final spacing = 16.w(context);
    final rows = <Widget>[];

    for (var i = 0; i < stats.length; i += columns) {
      final rowItems = stats.skip(i).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(
                  child: j < rowItems.length
                      ? CustomDonationStatisticCard(
                          value: rowItems[j].value,
                          label: rowItems[j].label,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: 16.h(context)),
          rows[i],
        ],
      ],
    );
  }

  static int _gridColumns(
    BuildContext context, {
    required int mobile,
  }) {
    if (ResponsiveHelper.isDesktop(context)) return 4;
    if (ResponsiveHelper.isTablet(context)) return 4;
    return mobile;
  }

  static double _gridItemWidth(
    double availableWidth,
    int columns,
    double gap,
    BuildContext context,
  ) {
    final spacing = Dimensions.pad(gap, context) * (columns - 1);
    return (availableWidth - spacing) / columns;
  }

  static Widget _buildFeaturedCampaignCard(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(28.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 20.s(context) : 24.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w(context),
                vertical: 6.h(context),
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGoldenWheat,
                borderRadius: BorderRadius.circular(18.r(context)),
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
              fontSize: isMobile ? 22.f(context) : 26.f(context),
              fontWeight: FontWeight.bold,
              height: 1.2,
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
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: isMobile ? double.infinity : 180.w(context),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGoldenWheat,
                  foregroundColor: AppColors.primaryForest,
                  padding: EdgeInsets.symmetric(
                    vertical: 14.h(context),
                    horizontal: 16.w(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r(context)),
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
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Text(
          actionLabel,
          style: TextStyle(
            color: AppColors.primaryForest,
            fontSize: 14.f(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
