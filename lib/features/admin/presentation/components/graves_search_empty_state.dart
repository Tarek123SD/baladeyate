import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class GravesSearchEmptyState extends StatelessWidget {
  const GravesSearchEmptyState({
    super.key,
    required this.hasQuery,
  });

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        hasQuery ? 'لا توجد نتائج مطابقة لبحثك.' : 'لا توجد سجلات مدافن.',
        textDirection: TextDirection.rtl,
        style: TextStyle(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
          fontSize: 14.f(context),
        ),
      ),
    );
  }
}
