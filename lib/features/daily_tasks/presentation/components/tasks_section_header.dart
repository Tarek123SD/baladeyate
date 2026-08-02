import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TasksSectionHeader extends StatelessWidget {
  const TasksSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.accent,
  });

  final String title;
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 4.w(context),
          height: 18.h(context),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          title,
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.w800,
            color: AppColors.primaryForest,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Text(
            '$count ${count == 1 ? 'مهمة' : 'مهام'}',
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}
