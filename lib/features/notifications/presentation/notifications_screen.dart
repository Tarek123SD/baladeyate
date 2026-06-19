import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_notification_card.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 4,
          automaticallyImplyLeading: false,
          title: Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/main');
                  }
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryForest,
                  size: 20.ic(context),
                ),
                padding: EdgeInsets.zero,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الإشعارات',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 20.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h(context)),
                    Text(
                      'يمكنك متابعة أحدث التنبيهات هنا',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF6D6D6D),
                        fontSize: 12.f(context),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 48.s(context)),
            ],
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 18.h(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'تحديد الكل كمقروء',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppColors.primaryGoldenWheat,
                              fontSize: 14.f(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w(context)),
                        Text(
                          'اليوم',
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 14.f(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22.h(context)),
                    const CustomNotificationCard(
                      time: 'منذ ساعتين',
                      title: 'تم قبول طلب تجديد الهوية',
                      message:
                          'تمت معالجة طلبك بنجاح. يمكنك الآن استلام هويتك الجديدة من مركز السجل المدني الأقرب إليك.',
                      icon: Icons.check_circle,
                      iconColor: AppColors.green,
                    ),
                    SizedBox(height: 18.h(context)),
                    const CustomNotificationCard(
                      time: 'أمس',
                      title: 'صيانة مجدولة لشبكة المياه',
                      message:
                          'نحيطكم علماً بوجود أعمال صيانة دورية في قطاع دمشق القديمة، مما سيؤدي لانقطاع مؤقت للمياه غداً من الساعة 10 صباحاً.',
                      icon: Icons.water_drop,
                      iconColor: AppColors.primaryForest,
                    ),
                    SizedBox(height: 18.h(context)),
                    const CustomNotificationCard(
                      time: 'قبل يومين',
                      title: 'تم تحديث بيانات العائلة بنجاح',
                      message:
                          'تمت مزامنة البيانات العائلية الجديدة مع السجل الرقمي المركزي. يمكنك الآن إصدار القيد العائلي إلكترونياً.',
                      icon: Icons.family_restroom,
                      iconColor: AppColors.secondaryForest,
                    ),
                    SizedBox(height: 40.h(context)),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48.ic(context),
                            color: const Color(0xFF9A9A9A),
                          ),
                          SizedBox(height: 14.h(context)),
                          Text(
                            'لا توجد إشعارات قديمة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF9A9A9A),
                              fontSize: 14.f(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h(context)),
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
