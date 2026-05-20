import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = 100.h(context);
    final horizontal = 24.s(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash_screen_wallpaper.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset('assets/images/Syrian_logo_icon_gold.png')
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 1000.ms,
                    curve: Curves.easeOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(0.9, 0.9),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            Positioned(
              bottom: bottom,
              left: horizontal,
              right: horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'الديوان الرقمي',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.s(context),
                      color: AppConstants.thirdGoldenWheat,
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    'الجمهورية العربية السورية',
                    style: TextStyle(
                      color: AppConstants.secondaryGoldenWheat,
                      fontSize: 20.s(context),
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    'المنصة الوطنية لخدمات المواطنة',
                    style: TextStyle(
                      color: AppConstants.thirdGoldenWheat,
                      fontSize: 18.s(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
