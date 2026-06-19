import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomDailyTaskCard extends StatelessWidget {
  const CustomDailyTaskCard({
    super.key,
    required this.title,
    required this.location,
    required this.distance,
    required this.time,
    required this.status,
    this.isSelected = false,
    this.onTap,
    this.onStart,
    this.onNavigate,
    this.onInfo,
  });

  final String title;
  final String location;
  final String distance;
  final String time;
  final DailyTaskStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onNavigate;
  final VoidCallback? onInfo;

  bool get _isCompleted => status == DailyTaskStatus.completed;
  bool get _isActive => status == DailyTaskStatus.highPriority;

  @override
  Widget build(BuildContext context) {
    final contentOpacity = _isCompleted ? 0.55 : 1.0;

    return Opacity(
      opacity: _isCompleted ? 0.92 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r(context)),
          child: Ink(
            padding: EdgeInsets.all(16.s(context)),
            decoration: BoxDecoration(
              color: _isCompleted
                  ? AppColors.thirdGoldenWheat.withValues(alpha: 0.45)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20.r(context)),
              border: Border.all(
                color: isSelected
                    ? AppColors.green
                    : AppColors.secondaryCharcoal.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: _isCompleted
                  ? null
                  : [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.green.withValues(alpha: 0.12)
                            : const Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: isSelected ? 20 : 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildBadge(context),
                      ),
                      SizedBox(height: 10.h(context)),
                      Opacity(
                        opacity: contentOpacity,
                        child: Text(
                          title,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 15.f(context),
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h(context)),
                      Opacity(
                        opacity: contentOpacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                location,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: 0.75),
                                  fontSize: 13.f(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w(context)),
                            Icon(
                              Icons.location_on_outlined,
                              size: 16.ic(context),
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.55),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w(context)),
                _buildSideInfo(context, contentOpacity),
                if (_isCompleted)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w(context)),
                    child: CircleAvatar(
                      radius: 18.s(context),
                      backgroundColor:
                          AppColors.primaryGoldenWheat.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.primaryGoldenWheat,
                        size: 20.ic(context),
                      ),
                    ),
                  ),
              ],
            ),
            if (_isActive) ...[
              SizedBox(height: 16.h(context)),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h(context),
                      child: ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r(context)),
                          ),
                        ),
                        child: Text(
                          'بدء المهمة',
                          style: TextStyle(
                            fontSize: 14.f(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w(context)),
                  _buildIconAction(
                    context,
                    icon: Icons.navigation_rounded,
                    onTap: onNavigate,
                  ),
                  SizedBox(width: 8.w(context)),
                  _buildIconAction(
                    context,
                    icon: Icons.info_outline_rounded,
                    onTap: onInfo,
                  ),
                ],
              ),
            ],
          ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final String label;

    switch (status) {
      case DailyTaskStatus.highPriority:
        bg = const Color(0xFFFFE8E8);
        fg = const Color(0xFFC62828);
        label = 'أولوية عالية';
      case DailyTaskStatus.scheduled:
        bg = AppColors.thirdGoldenWheat.withValues(alpha: 0.7);
        fg = AppColors.secondaryCharcoal.withValues(alpha: 0.8);
        label = 'مجدول';
      case DailyTaskStatus.completed:
        bg = AppColors.secondaryCharcoal.withValues(alpha: 0.08);
        fg = AppColors.secondaryCharcoal.withValues(alpha: 0.65);
        label = 'مكتمل';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 5.h(context),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.f(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSideInfo(BuildContext context, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 72.w(context),
        padding: EdgeInsets.symmetric(
          horizontal: 8.w(context),
          vertical: 10.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14.r(context)),
        ),
        child: Column(
          children: [
            Text(
              distance,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 13.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h(context)),
            Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                fontSize: 11.f(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconAction(
    BuildContext context, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 44.w(context),
      height: 44.h(context),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          backgroundColor: Colors.white,
        ),
        child: Icon(
          icon,
          size: 20.ic(context),
          color: AppColors.primaryForest,
        ),
      ),
    );
  }
}
