import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/app_responsive.dart';
import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: SizedBox(
          width: context.dim(42),
          height: context.dim(42),
          child: CircularProgressIndicator(
            color: AppColors.pageProgress(context),
          ),
        ),
      ),
    ),
  );
}
