import 'package:baladeyate/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Donations extends StatelessWidget {
  static const List<int> _amounts = [25000, 10000, 100000, 50000];

  const Donations({super.key});

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Featured Campaign Card
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.green,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryGoldenWheat,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Text(
                            'حملة مميزة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'إعادة إعمار المدارس التاريخية',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ساهم في ترميم الصروح التعليمية التي تعيد بناء التاريخ وتضمن مستقبلاً مشرقاً لأجيالنا القادمة.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: AppConstants.thirdGoldenWheat,
                          fontSize: 14,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: 160,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryGoldenWheat,
                            foregroundColor: AppConstants.primaryForest,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18),
                          label: const Text(
                            'تصدق الآن',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Statistics Cards
                Wrap(
                  runSpacing: 16,
                  spacing: 16,
                  children: [
                    _buildStatisticCard(context, '89K', 'متبرع نشط'),
                    _buildStatisticCard(context, '+145', 'مشروع مدعوم'),
                    _buildStatisticCard(context, '24/7', 'خدمة كاملة'),
                    _buildStatisticCard(context, '12', 'محافظة مستفيدة'),
                  ],
                ),
                const SizedBox(height: 28),
                // Active Campaigns Header
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الحملات النشطة',
                      style: TextStyle(
                        color: AppConstants.primaryForest,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'عرض الكل »',
                      style: TextStyle(
                        color: AppConstants.primaryForest,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Campaign Cards
                _buildCampaignCard(
                  label: 'صحي',
                  title: 'دعم الرعاية الصحية',
                  subtitle:
                      'تأمين المستلزمات الطبية والأدوية الأساسية للمراكز الصحية في المناطق المحتاجة.',
                  progress: 0.75,
                  statusLabel: '75% تم جمعه',
                  icon: Icons.local_hospital,
                  iconColor: AppConstants.secondaryForest,
                ),
                const SizedBox(height: 16),
                _buildCampaignCard(
                  label: 'إغاثي',
                  title: 'السلة الغذائية',
                  subtitle:
                      'توزيع سلال غذائية متكاملة للأسر المحتاجة خلال الشهر المبارك.',
                  progress: 0.4,
                  statusLabel: '40% تم جمعه',
                  icon: Icons.food_bank,
                  iconColor: AppConstants.primaryGoldenWheat,
                ),
                const SizedBox(height: 28),
                // Donation Amount Selection
                const Text(
                  'حدد قيمة التبرع',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppConstants.primaryForest,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'اختر المبلغ الذي ترغب في المساعدة به',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppConstants.secondaryCharcoal,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _amounts.map((amount) {
                    return _buildAmountButton(amount, context);
                  }).toList(),
                ),
                const SizedBox(height: 18),
                _buildCustomAmountField(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'تأكيد التبرع والمتابعة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
    );
  }
}

Widget _buildStatisticCard(BuildContext context, String value, String label) {
  return SizedBox(
    width: (MediaQuery.of(context).size.width - 68) / 2,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppConstants.primaryCharcoal, width: 0.3),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppConstants.primaryForest,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF7A7A7A),
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCampaignCard({
  required String label,
  required String title,
  required String subtitle,
  required double progress,
  required String statusLabel,
  required IconData icon,
  required Color iconColor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        // Icon area on the right
        Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(22),
              bottomRight: Radius.circular(22),
            ),
          ),
          child: Center(
            child: Icon(icon, color: iconColor, size: 52),
          ),
        ),
        // Content area on the left
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Label badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppConstants.primaryForest,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppConstants.secondaryCharcoal,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusLabel,
                      style: const TextStyle(
                        color: AppConstants.primaryForest,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'الهدف 50,000',
                      style: TextStyle(
                        color:
                            AppConstants.primaryForest.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    backgroundColor: AppConstants.thirdGoldenWheat,
                    valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAmountButton(int amount, BuildContext context) {
  const bool isSelected = false;
  return GestureDetector(
    onTap: () {},
    child: Container(
      width: (MediaQuery.of(context).size.width - 84) / 2,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppConstants.secondaryGoldenWheat,
          width: 1.4,
        ),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        '${amount.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (match) => ",")} ل.س',
        style: const TextStyle(
          color: AppConstants.primaryForest,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
  );
}

Widget _buildCustomAmountField() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      const Text(
        'مبلغ مخصص (ل.س)',
        style: TextStyle(
          color: AppConstants.primaryForest,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'أدخل القيمة يدوياً',
          hintStyle: const TextStyle(
            color: AppConstants.secondaryCharcoal,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppConstants.secondaryGoldenWheat,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFD9D2C2),
            ),
          ),
          suffixIcon: const Icon(
            Icons.add,
            color: AppConstants.primaryForest,
          ),
        ),
      ),
    ],
  );
}
