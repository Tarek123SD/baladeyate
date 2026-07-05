import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 3)),
      sl<AuthCubit>().restoreSession(),
    ]);

    if (!mounted) return;

    final state = sl<AuthCubit>().state;
    if (state is AuthSuccess) {
      context.go('/main');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = 100.h(context);
    final horizontal = 24.s(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.splashWallpaper),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Image.asset(AppAssets.logoGold)
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
                      fontSize: 28.f(context),
                      color: AppColors.thirdGoldenWheat,
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    'الجمهورية العربية السورية',
                    style: TextStyle(
                      color: AppColors.secondaryGoldenWheat,
                      fontSize: 20.f(context),
                    ),
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    'المنصة الوطنية لخدمات المواطنة',
                    style: TextStyle(
                      color: AppColors.thirdGoldenWheat,
                      fontSize: 18.f(context),
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
