import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// List card for the track-complaints screen.
/// Visual language matches [CustomDonationCampaignCard] and
/// [CustomProfileFamilyMemberCard]: white surface, soft tinted header,
/// golden-wheat meta chips, and forest typography.
class CustomTrackComplaintCard extends StatelessWidget {
  const CustomTrackComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  final Map<String, dynamic> complaint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = complaint['statusColor'] as Color;
    final statusFg =
        (complaint['statusFgColor'] as Color?) ?? AppColors.primaryForest;
    final statusIcon =
        (complaint['statusIcon'] as IconData?) ?? Icons.info_outline_rounded;
    final statusLabel = complaint['statusLabel'] as String;
    final priorityLabel = complaint['priorityLabel'] as String?;
    final priorityColor =
        (complaint['priorityColor'] as Color?) ?? AppColors.primaryForest;
    final category = complaint['category'] as String?;
    final icon = complaint['icon'] as IconData? ?? Icons.report_outlined;
    final title = complaint['title'] as String;
    final request = complaint['request'] as String;
    final date = complaint['date'] as String;
    final details = complaint['details'] as String?;
    final locationAddress = complaint['locationAddress'] as String?;
    final hasBodyContent = (details != null && details.isNotEmpty) ||
        (locationAddress != null && locationAddress.isNotEmpty);

    final radius = 24.r(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: AppColors.primaryForest.withValues(alpha: 0.06),
        highlightColor: AppColors.primaryForest.withValues(alpha: 0.03),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: statusFg.withValues(alpha: 0.22),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryForest.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: statusFg.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(
                  label: statusLabel,
                  foreground: statusFg,
                  background: statusColor,
                  icon: statusIcon,
                ),
                _CardHeader(
                  icon: icon,
                  accent: statusFg,
                  title: title,
                  request: request,
                  date: date,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16.w(context),
                    14.h(context),
                    16.w(context),
                    16.h(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (hasBodyContent) ...[
                        _BodyPreview(
                          details: details,
                          locationAddress: locationAddress,
                        ),
                        SizedBox(height: 14.h(context)),
                      ],
                      _CardFooter(
                        priorityLabel: priorityLabel,
                        priorityColor: priorityColor,
                        category: category,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.label,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color foreground;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 11.h(context),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            foreground.withValues(alpha: 0.22),
            background,
            background.withValues(alpha: 0.7),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: foreground.withValues(alpha: 0.25)),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 34.w(context),
            height: 34.w(context),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: foreground.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18.ic(context),
              color: foreground,
            ),
          ),
          SizedBox(width: 10.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الطلب',
                  style: TextStyle(
                    fontSize: 10.f(context),
                    fontWeight: FontWeight.w600,
                    color: foreground.withValues(alpha: 0.72),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.f(context),
                    fontWeight: FontWeight.w800,
                    color: foreground,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8.w(context),
            height: 8.w(context),
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: foreground.withValues(alpha: 0.45),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.icon,
    required this.accent,
    required this.title,
    required this.request,
    required this.date,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String request;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w(context),
        14.h(context),
        16.w(context),
        14.h(context),
      ),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: accent,
            width: 4.w(context),
          ),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w(context),
            height: 48.w(context),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r(context)),
              border: Border.all(
                color: accent.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              icon,
              color: accent,
              size: 24.ic(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' عنوان الشكوى',
                  style: TextStyle(
                    fontSize: 10.f(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.bold,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 10.h(context)),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    _MetaPill(label: request),
                    SizedBox(width: 8.w(context)),
                    Expanded(
                      child: Row(
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 13.ic(context),
                            color: AppColors.secondaryCharcoal
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 5.w(context)),
                          Flexible(
                            child: Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.f(context),
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.72),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyPreview extends StatelessWidget {
  const _BodyPreview({
    this.details,
    this.locationAddress,
  });

  final String? details;
  final String? locationAddress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.s(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (details != null && details!.isNotEmpty)
            _BodyField(
              label: 'تفاصيل الشكوى',
              value: details!,
            ),
          if (details != null &&
              details!.isNotEmpty &&
              locationAddress != null &&
              locationAddress!.isNotEmpty)
            SizedBox(height: 12.h(context)),
          if (locationAddress != null && locationAddress!.isNotEmpty)
            _BodyField(
              label: 'عنوان الموقع',
              value: locationAddress!,
              icon: Icons.location_on_outlined,
              maxLines: 3,
            ),
        ],
      ),
    );
  }
}

class _BodyField extends StatelessWidget {
  const _BodyField({
    required this.label,
    required this.value,
    this.icon,
    this.maxLines = 2,
  });

  final String label;
  final String value;
  final IconData? icon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13.ic(context),
                color: AppColors.thirdForest,
              ),
              SizedBox(width: 4.w(context)),
            ],
            Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 10.f(context),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryForest.withValues(alpha: 0.65),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h(context)),
        Text(
          value,
          textAlign: TextAlign.right,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.f(context),
            height: 1.55,
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.82),
          ),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.priorityLabel,
    required this.priorityColor,
    required this.category,
  });

  final String? priorityLabel;
  final Color priorityColor;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final hasPriority =
        priorityLabel != null && priorityLabel!.trim().isNotEmpty;
    final hasCategory = category != null && category!.trim().isNotEmpty;

    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: hasPriority || hasCategory
              ? Wrap(
                  spacing: 6.w(context),
                  runSpacing: 6.h(context),
                  alignment: WrapAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    if (hasPriority)
                      _TagPill(
                        label: priorityLabel!,
                        color: priorityColor,
                        icon: Icons.flag_rounded,
                      ),
                    if (hasCategory)
                      _TagPill(
                        label: category!,
                        color: AppColors.thirdForest,
                        icon: Icons.category_rounded,
                      ),
                  ],
                )
              : Text(
                  'شكوى بلدية',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.5),
                  ),
                ),
        ),
        SizedBox(width: 8.w(context)),
        Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'التفاصيل',
              style: TextStyle(
                fontSize: 12.f(context),
                fontWeight: FontWeight.w700,
                color: AppColors.primaryForest,
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 12.ic(context),
              color: AppColors.primaryForest,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 5.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.f(context),
          fontWeight: FontWeight.w700,
          color: AppColors.primaryForest,
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 5.h(context),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 12.ic(context), color: color),
          SizedBox(width: 4.w(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
