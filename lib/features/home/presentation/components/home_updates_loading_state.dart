import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeUpdatesLoadingState extends StatelessWidget {
  const HomeUpdatesLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h(context)),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 36.s(context),
              height: 36.s(context),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.pageProgress(context),
              ),
            ),
            SizedBox(height: 16.h(context)),
            Text(
              'جاري تحميل التحديثات...',
              style: TextStyle(
                fontSize: 13.f(context),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
