import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsEmptyState extends StatelessWidget {
  const TransactionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h(context)),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 56.ic(context),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h(context)),
          Text(
            'لا توجد معاملات حالياً',
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'يمكنك تقديم معاملة جديدة من خلال الزر في الأسفل',
            style: TextStyle(
              fontSize: 12.f(context),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
