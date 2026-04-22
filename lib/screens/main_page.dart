import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

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
                SizedBox(
                  width: 250,
                  // height: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/Syrian_horizontal_dark_green.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.black87,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.search,
                        color: Colors.black87,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Greeting Card
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.secondaryForest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'صباح الخير',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'أهلا بك، أحمد',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                textDirection: TextDirection.rtl,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'الهوية الرقمية مفعلة',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        const SizedBox(height: 40),
                        // Quick Services
                        Column(
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الخدمات السريعة',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                  textDirection: TextDirection.rtl,
                                ),
                                Container(
                                  width: 60,
                                  height: 3,
                                  color: AppConstants.secondaryForest,
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _buildServiceCard(
                                  context,
                                  'تقديم شكوى',
                                  Icons.volume_up,
                                  Colors.white,
                                  AppConstants.primaryForest,
                                ),
                                const SizedBox(width: 12),
                                _buildServiceCard(
                                  context,
                                  'المتحف الثقافي',
                                  Icons.groups,
                                  Colors.white,
                                  AppConstants.primaryForest,
                                ),
                                const SizedBox(width: 12),
                                _buildServiceCard(
                                  context,
                                  'البحث في المدافن',
                                  Icons.search,
                                  Colors.white,
                                  AppConstants.primaryForest,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Latest Updates
                        Column(
                          children: [
                            Row(
                              textDirection: TextDirection.rtl,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'آخر التحديثات',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                  textDirection: TextDirection.rtl,
                                ),
                                Text(
                                  'عرض الكل',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppConstants.primaryForest,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildUpdateCard(
                              context,
                              'تم قبول طلب تجديد الهوية',
                              'شهر ساعتين',
                              'سيتم إرسال بطاقتك المجددة عبر البريد الحكومي خلال 7 أيام عمل.',
                              Icons.verified,
                              Colors.amber,
                            ),
                            const SizedBox(height: 12),
                            _buildUpdateCard(
                              context,
                              'فاتورة الكهرباء جاهرة',
                              'أمس',
                              'صدرت فاتورة الكهرباء والمياه بقيمة 15,200 ل.س. يرجى الدفع.',
                              Icons.receipt,
                              Colors.grey,
                            ),
                            const SizedBox(height: 12),
                            _buildUpdateCard(
                              context,
                              'تنبيه: صيانة عامة',
                              '28 شهرين',
                              'ستُقفل خدمات الدفع الإلكترونية من اليوم 01 من الساعة 2-12 فجراً.',
                              Icons.error,
                              Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Heritage Section
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                height: 200,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/images/splash_screen_wallpaper.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.7),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'تراثنا، هويتنا',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'اكتشف المزيد عن الخدمات السياحية والثقافية للمدن الأثرية بمنصة المواطن',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white70,
                                            ),
                                        textDirection: TextDirection.rtl,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppConstants.secondaryForest,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'الملف',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'التنبيهات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt),
                  label: 'المعاملات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color? bgColor,
    Color? iconColor,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateCard(
    BuildContext context,
    String title,
    String time,
    String description,
    IconData icon,
    Color iconBgColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconBgColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
