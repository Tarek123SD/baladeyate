import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintMapBox extends StatelessWidget {
  const CustomComplaintMapBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h(context),
      decoration: BoxDecoration(
        color: AppColors.secondaryGoldenWheat,
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Center(
        child: Icon(
          Icons.location_pin,
          size: 30.ic(context),
          color: AppColors.primaryForest,
        ),
      ),
    );
  }
}
