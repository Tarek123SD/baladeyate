import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsHeaderCard extends StatelessWidget {
  const TrackComplaintsHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryForest,
        borderRadius: BorderRadius.circular(16.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.s(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: Colors.white,
              size: 26.ic(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز تتبع الشكاوى',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'متابعة فورية ومباشرة لحالة بلاغاتك ومعالجتها',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
