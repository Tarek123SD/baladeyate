import 'package:baladeyate/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

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
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h(context)),
                  _buildHeader(context),
                  SizedBox(height: 24.h(context)),
                  _buildProfileCard(context),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'الإعدادات العامة'),
                  SizedBox(height: 16.h(context)),
                  _buildSettingItem(
                    context,
                    title: 'تغيير اللغة',
                    subtitle: 'العربية',
                    icon: Icons.language,
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildSettingItem(
                    context,
                    title: 'تغيير كلمة المرور',
                    icon: Icons.lock_outline,
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildSectionTitle(context, 'القانونية والمعلومات'),
                  SizedBox(height: 16.h(context)),
                  _buildSettingItem(
                    context,
                    title: 'سياسة الخصوصية',
                    icon: Icons.privacy_tip_outlined,
                  ),
                  SizedBox(height: 12.h(context)),
                  _buildSettingItem(
                    context,
                    title: 'الشروط والأحكام العامة',
                    icon: Icons.gavel_outlined,
                  ),
                  SizedBox(height: 32.h(context)),
                  _buildLogoutButton(context),
                  SizedBox(height: 24.h(context)),
                  _buildFooterText(context),
                  SizedBox(height: 24.h(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Text(
        'الإعدادات ',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryForest,
            ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w(context)),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppConstants.secondaryCharcoal.withValues(alpha: 0.5)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                  'أحمد المنصور',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryForest,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  'رقم الهوية: ٠١٠٩٢٨٣٤٦٧',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 16.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w(context),
                    vertical: 8.h(context),
                  ),
                  decoration: BoxDecoration(
                    color:
                        AppConstants.thirdGoldenWheat.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16.r(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 8.s(context),
                        height: 8.s(context),
                        decoration: const BoxDecoration(
                          color: Color(0xFF988561),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w(context)),
                      Text(
                        'حساب موثّق حكومياً',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppConstants.primaryForest,
                              fontWeight: FontWeight.w600,
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w(context)),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CircleAvatar(
                radius: 42.s(context),
                backgroundColor:
                    AppConstants.primaryForest.withValues(alpha: 0.12),
                child: CircleAvatar(
                  radius: 38.s(context),
                  backgroundColor: AppConstants.secondaryForest,
                  child: Icon(
                    Icons.person,
                    size: 40.s(context),
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 34.s(context),
                  height: 34.s(context),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryForest,
                    borderRadius: BorderRadius.circular(12.r(context)),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 18.s(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryForest,
          ),
      textDirection: TextDirection.rtl,
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 18.h(context),
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppConstants.secondaryCharcoal.withValues(alpha: 0.5)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
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
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppConstants.primaryForest,
                      ),
                  textDirection: TextDirection.rtl,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 6.h(context)),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_back_ios_new,
            size: 18.s(context),
            color: Colors.grey[500],
          ),
          SizedBox(width: 16.w(context)),
          Container(
            width: 44.s(context),
            height: 44.s(context),
            decoration: BoxDecoration(
              color: AppConstants.thirdGoldenWheat,
              borderRadius: BorderRadius.circular(16.r(context)),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryForest,
              size: 22.s(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 56.h(context),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r(context)),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'تسجيل الخروج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(width: 12.w(context)),
            Icon(
              Icons.logout,
              color: Colors.white,
              size: 22.s(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'V2.4.0 إصدار النظام',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 8.h(context)),
        Text(
          'الدعم الفني الحكومي المركز',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppConstants.primaryForest,
                fontWeight: FontWeight.w600,
              ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
