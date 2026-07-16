import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Live complaint statistics row that navigates to the tracking tab on tap.
class StatsOverview extends StatelessWidget {
  const StatsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComplaintsCubit, ComplaintsState>(
      builder: (context, state) {
        final total = state is ComplaintsLoaded ? state.totalCount : 0;
        final inProgress =
            state is ComplaintsLoaded ? state.inProgressCount : 0;
        final resolved = state is ComplaintsLoaded ? state.resolvedCount : 0;
        final isLoading = state is ComplaintsLoading;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/track'),
            borderRadius: BorderRadius.circular(20.r(context)),
            child: Container(
              padding: EdgeInsets.all(16.s(context)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryForest.withValues(alpha: 0.08),
                    blurRadius: 16.r(context),
                    offset: Offset(0, 4.h(context)),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new,
                        size: 14.s(context),
                        color: AppColors.primaryForest,
                      ),
                      Text(
                        'ملخص الشكاوى',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryForest,
                            ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h(context)),
                  if (isLoading)
                    _loadingRow(context)
                  else
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'الإجمالي',
                            count: total,
                            icon: Icons.assignment_outlined,
                            color: AppColors.primaryForest,
                          ),
                        ),
                        SizedBox(width: 10.s(context)),
                        Expanded(
                          child: _StatTile(
                            label: 'قيد المعالجة',
                            count: inProgress,
                            icon: Icons.hourglass_top_outlined,
                            color: AppColors.secondaryGoldenWheat,
                          ),
                        ),
                        SizedBox(width: 10.s(context)),
                        Expanded(
                          child: _StatTile(
                            label: 'تم الحل',
                            count: resolved,
                            icon: Icons.check_circle_outline,
                            color: AppColors.thirdForest,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loadingRow(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index < 2 ? 10.s(context) : 0),
            child: Container(
              height: 72.h(context),
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(14.r(context)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.s(context),
        vertical: 12.h(context),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r(context)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.s(context)),
          SizedBox(height: 6.h(context)),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20.f(context),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h(context)),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
