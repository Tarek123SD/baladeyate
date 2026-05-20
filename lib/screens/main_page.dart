import 'package:baladeyate/widgets/custom_card.dart';
import 'package:baladeyate/widgets/greeting_card.dart';
import 'package:baladeyate/widgets/section_header.dart';
import 'package:baladeyate/widgets/update_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import '../widgets/custom_app_bar.dart';
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
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(24.s(context)),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Greeting Card
                      const GreetingCard(
                        greeting: 'صباح الخير',
                        name: 'أهلا بك، أحمد',
                      ),
                      SizedBox(height: 40.h(context)),
                      SizedBox(height: 40.h(context)),
                      // Quick Services
                      Column(
                        children: [
                          const SectionHeader(title: 'الخدمات السريعة'),
                          SizedBox(height: 20.h(context)),
                          _quickServiceCards(context),
                        ],
                      ),
                      SizedBox(height: 40.h(context)),
                      // Latest Updates
                      Column(
                        children: [
                          const SectionHeader(
                            title: 'آخر التحديثات',
                            actionText: 'عرض الكل',
                          ),
                          SizedBox(height: 16.h(context)),
                          UpdateCard(
                            title: 'تم قبول طلب تجديد الهوية',
                            time: 'شهر ساعتين',
                            description:
                                'سيتم إرسال بطاقتك المجددة عبر البريد الحكومي خلال 7 أيام عمل.',
                            icon: Icons.verified,
                            iconBgColor: Colors.amber,
                          ),
                          SizedBox(height: 12.h(context)),
                          UpdateCard(
                            title: 'فاتورة الكهرباء جاهرة',
                            time: 'أمس',
                            description:
                                'صدرت فاتورة الكهرباء والمياه بقيمة 15,200 ل.س. يرجى الدفع.',
                            icon: Icons.receipt,
                            iconBgColor: Colors.grey,
                          ),
                          SizedBox(height: 12.h(context)),
                          UpdateCard(
                            title: 'تنبيه: صيانة عامة',
                            time: '28 شهرين',
                            description:
                                'ستُقفل خدمات الدفع الإلكترونية من اليوم 01 من الساعة 2-12 فجراً.',
                            icon: Icons.error,
                            iconBgColor: Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h(context)),
                      // Heritage Section
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r(context)),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 200.h(context),
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
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                padding: EdgeInsets.all(16.s(context)),
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
                                    SizedBox(height: 4.h(context)),
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
                      SizedBox(height: 40.h(context)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickServiceCards(BuildContext context) {
    final gap = 12.s(context);
    Widget tile(String title, IconData icon) {
      return CustomCard(
        title: title,
        icon: icon,
        bgColor: Colors.white,
        iconColor: AppConstants.primaryForest,
      );
    }

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile('تقديم شكوى', Icons.volume_up),
          SizedBox(height: gap),
          tile('المتحف الثقافي', Icons.groups),
          SizedBox(height: gap),
          tile('البحث في المدافن', Icons.search),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: tile('تقديم شكوى', Icons.volume_up)),
        SizedBox(width: gap),
        Expanded(child: tile('المتحف الثقافي', Icons.groups)),
        SizedBox(width: gap),
        Expanded(child: tile('البحث في المدافن', Icons.search)),
      ],
    );
  }
}
