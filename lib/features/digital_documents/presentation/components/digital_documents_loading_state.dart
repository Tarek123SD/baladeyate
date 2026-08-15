import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DigitalDocumentsLoadingState extends StatelessWidget {
  const DigitalDocumentsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.pageProgress(context),
          ),
          SizedBox(height: 14.h(context)),
          Text(
            'جاري تحميل الوثائق الرقمية...',
            style: TextStyle(
              fontSize: 13.f(context),
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
