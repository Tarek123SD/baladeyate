import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';

class BuildingScreen extends StatelessWidget {
  const BuildingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w(context)),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h(context)),
                Text(
                  'معلومات المبنى',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 28.s(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Text(
                  'تفاصيل الموقع، الحالة الحالية، والمهام المستقبلية الخاصة بالمبنى.',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14.s(context),
                    color: const Color(0xFF6D6D6D),
                    height: 1.8,
                  ),
                ),
                SizedBox(height: 26.h(context)),
                _buildHeaderCard(context),
                SizedBox(height: 24.h(context)),
                _buildStatsSection(context),
                SizedBox(height: 24.h(context)),
                _buildOverviewSection(context),
                SizedBox(height: 24.h(context)),
                _buildActionButtons(context),
                SizedBox(height: 30.h(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final isMobile = context.isMobile;
    final imageHeight = isMobile ? 220.h(context) : 320.h(context);

    final imageCard = ClipRRect(
      borderRadius: BorderRadius.circular(28.r(context)),
      child: Container(
        height: imageHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/building_info.png',
          fit: BoxFit.cover,
        ),
      ),
    );

    final textInfoCard = _buildTextInfoCard(context);

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              imageCard,
              SizedBox(height: 20.h(context)),
              textInfoCard,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: textInfoCard),
              SizedBox(width: 20.w(context)),
              Expanded(child: imageCard),
            ],
          );
  }

  Widget _buildTextInfoCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w(context),
        vertical: 20.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المبنى الزراعي رقم 12',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 24.s(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 10.h(context)),
                    Text(
                      'شارع الثورة، دمشق • المساحة 520 م²',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13.s(context),
                        color: const Color(0xFF6D6D6D),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w(context),
                  vertical: 10.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryForest,
                  borderRadius: BorderRadius.circular(18.r(context)),
                ),
                child: Text(
                  'نشط',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.s(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h(context)),
          Wrap(
            runSpacing: 10.h(context),
            spacing: 10.w(context),
            children: [
              _buildTag(context, 'مسح الموقع'),
              _buildTag(context, 'انتظار الموافقة'),
              _buildTag(context, 'خطر متوسط'),
            ],
          ),
          SizedBox(height: 20.h(context)),
          Text(
            'وصف مبسط للمبنى واحتياجاته الحالية. يمكن أن تتضمن معلومات عن حالة البناء، التهوية، ومدى جاهزية الموقع للعمل القادم.',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.s(context),
              color: const Color(0xFF6D6D6D),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w(context),
        vertical: 8.h(context),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4EF),
        borderRadius: BorderRadius.circular(18.r(context)),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: AppColors.primaryForest,
          fontSize: 12.s(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final isMobile = context.isMobile;
    final cards = [
      _buildStatCard(context, 'الحالة', 'جاهز'),
      _buildStatCard(context, 'الفني المسؤول', 'سعيد حمود'),
      _buildStatCard(context, 'آخر فحص', '14 مايو'),
    ];

    return isMobile
        ? Column(
            children: cards
                .map((card) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h(context)),
                      child: card,
                    ))
                .toList(),
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: cards
                .map((card) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 12.w(context)),
                        child: card,
                      ),
                    ))
                .toList(),
          );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 18.h(context),
        horizontal: 18.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 13.s(context),
              color: const Color(0xFF6D6D6D),
            ),
          ),
          SizedBox(height: 10.h(context)),
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18.s(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22.w(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ملخص المهمة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 18.s(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 16.h(context)),
          _buildOverviewRow(context, 'نوع المهمة', 'مسح المبنى والتقارير'),
          SizedBox(height: 12.h(context)),
          _buildOverviewRow(context, 'الوقت المقدر', '3 ساعات'),
          SizedBox(height: 12.h(context)),
          _buildOverviewRow(context, 'المعدات', 'كاميرا، طابعة، خرائط الموقع'),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 13.s(context),
              color: const Color(0xFF6D6D6D),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.s(context),
              color: AppColors.primaryForest,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isMobile = context.isMobile;

    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildPrimaryButton(context, 'بدء التحقق'),
              SizedBox(height: 14.h(context)),
              _buildSecondaryButton(context, 'عرض الخريطة'),
            ],
          )
        : Row(
            children: [
              Expanded(child: _buildPrimaryButton(context, 'بدء التحقق')),
              SizedBox(width: 16.w(context)),
              Expanded(child: _buildSecondaryButton(context, 'عرض الخريطة')),
            ],
          );
  }

  Widget _buildPrimaryButton(BuildContext context, String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryForest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 18.h(context),
        ),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 16.s(context),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String label) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primaryForest, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 18.h(context),
        ),
      ),
      child: Text(
        label,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 16.s(context),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryForest,
        ),
      ),
    );
  }
}
