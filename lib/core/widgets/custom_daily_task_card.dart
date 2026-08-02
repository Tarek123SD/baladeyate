import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Compact field-task card with clear hierarchy:
/// status row → title → location → primary action.
class CustomDailyTaskCard extends StatelessWidget {
  const CustomDailyTaskCard({
    super.key,
    required this.title,
    required this.location,
    required this.statusLabel,
    required this.status,
    this.metaLabel,
    this.isSelected = false,
    this.isPriority = false,
    this.emphasized = false,
    this.selectionHint,
    this.onTap,
    this.onStart,
    this.onNavigate,
    this.startLabel,
  });

  final String title;
  final String location;
  final String statusLabel;
  final String? metaLabel;
  final DailyTaskStatus status;
  final bool isSelected;
  final bool isPriority;
  final bool emphasized;
  final String? selectionHint;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onNavigate;
  final String? startLabel;

  bool get _isCompleted => status == DailyTaskStatus.completed;
  String get _resolvedStartLabel =>
      startLabel ??
      (status == DailyTaskStatus.highPriority ? 'متابعة المهمة' : 'بدء المهمة');

  Color get _accentColor {
    if (isSelected) return AppColors.primaryForest;
    if (emphasized) return AppColors.thirdForest;
    return switch (status) {
      DailyTaskStatus.highPriority => const Color(0xFFE65100),
      DailyTaskStatus.scheduled => AppColors.primaryGoldenWheat,
      DailyTaskStatus.completed => AppColors.thirdForest,
    };
  }

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);

    return Material(
      color: Colors.transparent,
      elevation: _isCompleted ? 0 : (isSelected ? 3 : 1),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            color: _isCompleted
                ? const Color(0xFFF3F1EA)
                : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryForest.withValues(alpha: 0.55)
                  : Colors.black.withValues(alpha: 0.05),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4.w(context),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      11.w(context),
                      10.h(context),
                      10.w(context),
                      10.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: 6.h(context)),
                        Text(
                          title,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.primaryForest.withValues(
                              alpha: _isCompleted ? 0.72 : 1,
                            ),
                            fontSize: 14.f(context),
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        SizedBox(height: 4.h(context)),
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 13.ic(context),
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.5),
                            ),
                            SizedBox(width: 3.w(context)),
                            Expanded(
                              child: Text(
                                location,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.secondaryCharcoal
                                      .withValues(alpha: 0.7),
                                  fontSize: 11.f(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isSelected && selectionHint != null) ...[
                          SizedBox(height: 6.h(context)),
                          _SelectionBanner(text: selectionHint!),
                        ],
                        if (onStart != null || onNavigate != null) ...[
                          SizedBox(height: 10.h(context)),
                          _buildActions(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _StatusPill(
          label: statusLabel,
          color: _accentColor,
          completed: _isCompleted,
        ),
        if (isPriority) ...[
          SizedBox(width: 5.w(context)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 7.w(context),
              vertical: 3.h(context),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E8),
              borderRadius: BorderRadius.circular(16.r(context)),
            ),
            child: Text(
              'أولوية',
              style: TextStyle(
                color: const Color(0xFFC62828),
                fontSize: 9.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const Spacer(),
        if (metaLabel != null && metaLabel!.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 7.w(context),
              vertical: 3.h(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(16.r(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.near_me_outlined,
                  size: 11.ic(context),
                  color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                ),
                SizedBox(width: 2.w(context)),
                Text(
                  metaLabel!,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
                    fontSize: 10.f(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )
        else if (_isCompleted)
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.thirdForest,
            size: 16.ic(context),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final buttonRadius = BorderRadius.circular(10.r(context));
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        if (onStart != null)
          Expanded(
            child: SizedBox(
              height: 36.h(context),
              child: FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context)),
                  shape: RoundedRectangleBorder(borderRadius: buttonRadius),
                ),
                child: Text(
                  _resolvedStartLabel,
                  style: TextStyle(
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )
        else if (onNavigate != null)
          Expanded(
            child: SizedBox(
              height: 36.h(context),
              child: FilledButton.icon(
                onPressed: onNavigate,
                icon: Icon(Icons.map_rounded, size: 16.ic(context)),
                label: Text(
                  startLabel ?? 'عرض على الخريطة',
                  style: TextStyle(
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryForest,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 10.w(context)),
                  shape: RoundedRectangleBorder(borderRadius: buttonRadius),
                ),
              ),
            ),
          ),
        if (onStart != null && onNavigate != null) ...[
          SizedBox(width: 6.w(context)),
          SizedBox(
            width: 36.w(context),
            height: 36.h(context),
            child: IconButton.outlined(
              onPressed: onNavigate,
              tooltip: 'فتح على الخريطة',
              style: IconButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: AppColors.primaryForest.withValues(alpha: 0.25),
                ),
                shape: RoundedRectangleBorder(borderRadius: buttonRadius),
              ),
              icon: Icon(Icons.map_outlined, size: 17.ic(context)),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.completed,
  });

  final String label;
  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w(context),
        vertical: 3.h(context),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: completed ? 0.12 : 0.14),
        borderRadius: BorderRadius.circular(16.r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 6.s(context),
            height: 6.s(context),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w(context)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBanner extends StatelessWidget {
  const _SelectionBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w(context),
        vertical: 5.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r(context)),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            Icons.map_rounded,
            size: 13.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(width: 5.w(context)),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 10.f(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
