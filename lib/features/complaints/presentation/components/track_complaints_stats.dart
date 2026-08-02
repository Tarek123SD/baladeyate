import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsStats extends StatelessWidget {
  const TrackComplaintsStats({
    super.key,
    required this.state,
  });

  final ComplaintsLoaded state;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: 'إجمالي',
        value: '${state.totalCount}',
        color: AppColors.primaryForest,
        icon: AppIcons.statsTotal,
      ),
      (
        title: 'قيد المعالجة',
        value: '${state.inProgressCount}',
        color: const Color(0xFFB26A00),
        icon: AppIcons.statsPending,
      ),
      (
        title: 'تم الحل',
        value: '${state.resolvedCount}',
        color: const Color(0xFF1B7B3A),
        icon: AppIcons.statsDone,
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w(context)),
            padding: EdgeInsets.symmetric(
              horizontal: 10.w(context),
              vertical: 10.h(context),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Icon(item.icon, size: 16.ic(context), color: item.color),
                  ],
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 17.f(context),
                    fontWeight: FontWeight.bold,
                    color: item.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
