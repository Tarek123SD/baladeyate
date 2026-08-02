import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsListHeader extends StatelessWidget {
  const TrackComplaintsListHeader({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          width: 4.w(context),
          height: 16.h(context),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة الشكاوي',
          style: TextStyle(
            fontSize: 15.f(context),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Text(
            '$count نتيجة',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
