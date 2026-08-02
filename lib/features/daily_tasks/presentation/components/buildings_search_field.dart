import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingsSearchField extends StatelessWidget {
  const BuildingsSearchField({
    super.key,
    required this.controller,
    required this.query,
  });

  final TextEditingController controller;
  final String query;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: AppColors.primaryForest,
        fontSize: 13.f(context),
      ),
      decoration: InputDecoration(
        hintText: 'ابحث بالاسم أو رقم العقار',
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(
          AppIcons.search,
          color: AppColors.primaryForest.withValues(alpha: 0.55),
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  controller.clear();
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 10.h(context),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: BorderSide(
            color: AppColors.primaryForest.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: BorderSide(
            color: AppColors.primaryForest.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r(context)),
          borderSide: const BorderSide(color: AppColors.primaryForest),
        ),
      ),
    );
  }
}
