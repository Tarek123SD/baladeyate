import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintUploadBox extends StatelessWidget {
  const CustomComplaintUploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h(context),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryForest),
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file,
              size: 30.ic(context),
              color: AppColors.primaryForest,
            ),
            SizedBox(height: 10.s(context)),
            Text(
              'رفع صور أو مستندات',
              style: TextStyle(
                fontSize: 14.f(context),
                color: AppColors.primaryForest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
