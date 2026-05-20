import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppConstants.primaryForest,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'الإشعارات',
                      style: TextStyle(
                        color: AppConstants.primaryForest,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'يمكنك متابعة أحدث التنبيهات هنا',
                      style: TextStyle(
                        color: Color(0xFF6D6D6D),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.secondaryForest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings,
                  color: AppConstants.primaryForest,
                  size: 24,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تحديد الكل كمقروء',
                          style: TextStyle(
                            color: AppConstants.primaryGoldenWheat,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'اليوم',
                          style: TextStyle(
                            color: AppConstants.primaryForest,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildNotificationCard(
                      time: 'منذ ساعتين',
                      title: 'تم قبول طلب تجديد الهوية',
                      message:
                          'تمت معالجة طلبك بنجاح. يمكنك الآن استلام هويتك الجديدة من مركز السجل المدني الأقرب إليك.',
                      icon: Icons.check_circle,
                      iconColor: AppConstants.green,
                    ),
                    const SizedBox(height: 18),
                    _buildNotificationCard(
                      time: 'أمس',
                      title: 'صيانة مجدولة لشبكة المياه',
                      message:
                          'نحيطكم علماً بوجود أعمال صيانة دورية في قطاع دمشق القديمة، مما سيؤدي لانقطاع مؤقت للمياه غداً من الساعة 10 صباحاً.',
                      icon: Icons.water_drop,
                      iconColor: AppConstants.primaryForest,
                    ),
                    const SizedBox(height: 18),
                    _buildNotificationCard(
                      time: 'قبل يومين',
                      title: 'تم تحديث بيانات العائلة بنجاح',
                      message:
                          'تمت مزامنة البيانات العائلية الجديدة مع السجل الرقمي المركزي. يمكنك الآن إصدار القيد العائلي إلكترونياً.',
                      icon: Icons.family_restroom,
                      iconColor: AppConstants.secondaryForest,
                    ),
                    const SizedBox(height: 40),
                    const Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Color(0xFF9A9A9A),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'لا توجد إشعارات قديمة',
                          style: TextStyle(
                            color: Color(0xFF9A9A9A),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String time,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: AppConstants.primaryForest,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF5B5B5B),
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -6,
          top: 16,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: iconColor.withValues(alpha: 0.16),
            child: Icon(
              icon,
              size: 28,
              color: iconColor,
            ),
          ),
        ),
      ],
    );
  }
}
