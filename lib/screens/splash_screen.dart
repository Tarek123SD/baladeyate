import 'package:baladeyate/screens/signup.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignUP()),
        );
      },
      child: Scaffold(
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
                child: Image.asset('assets/images/Syrian_logo_icon_gold.png'),
              ),
              const Positioned(
                bottom: 100,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'الديوان الرقمي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: AppConstants.thirdGoldenWheat,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'الجمهورية العربية السورية',
                      style: TextStyle(
                        color: AppConstants.secondaryGoldenWheat,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'المنصة الوطنية لخدمات المواطنة',
                      style: TextStyle(
                        color: AppConstants.thirdGoldenWheat,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
