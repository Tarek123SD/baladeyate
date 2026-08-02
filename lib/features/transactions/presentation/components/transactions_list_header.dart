import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsListHeader extends StatelessWidget {
  const TransactionsListHeader({
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
            borderRadius: BorderRadius.circular(2.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة المعاملات المتاحة',
          style: TextStyle(
            fontSize: 14.f(context),
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
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Text(
            '$count معاملة',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
