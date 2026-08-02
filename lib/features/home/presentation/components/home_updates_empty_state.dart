import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeUpdatesEmptyState extends StatelessWidget {
  const HomeUpdatesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.s(context)),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 64.ic(context),
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 16.h(context)),
          Text(
            'لا توجد تحديثات حالياً',
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
            textDirection: TextDirection.rtl,
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'تأكد من اختيار تصنيف آخر أو تفقد الإشعارات لاحقاً',
            style: TextStyle(
              fontSize: 12.f(context),
              color: Colors.grey[400],
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
