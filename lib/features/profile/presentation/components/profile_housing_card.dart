import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/profile/models/household.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ProfileHousingCard extends StatelessWidget {
  const ProfileHousingCard({
    super.key,
    required this.household,
    required this.isLoading,
    this.errorMessage,
    this.onRetry,
  });

  final Household? household;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sectionHeader(context),
          if (isLoading) ...[
            SizedBox(height: 20.h(context)),
            _loadingSkeleton(context),
          ] else if (errorMessage != null) ...[
            SizedBox(height: 16.h(context)),
            _errorSection(context, errorMessage!),
          ] else ...[
            SizedBox(height: 16.h(context)),
            _infoGrid(context),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: 5.w(context),
          height: 20.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'بيانات السكن',
          style: TextStyle(
            fontSize: 16.f(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryForest,
          ),
          textDirection: TextDirection.rtl,
        ),
        const Spacer(),
        Icon(
          Icons.home_work_outlined,
          color: AppColors.primaryForest.withValues(alpha: 0.6),
          size: 20.ic(context),
        ),
      ],
    );
  }

  Widget _infoGrid(BuildContext context) {
    final items = <_InfoItem>[
      _InfoItem(
        title: 'المبنى',
        value: household?.buildingName ?? '—',
        icon: Icons.apartment_rounded,
      ),
      _InfoItem(
        title: 'العنوان',
        value: household?.address ?? '—',
        icon: Icons.signpost_outlined,
      ),
      if (household?.district != null && household!.district!.trim().isNotEmpty)
        _InfoItem(
          title: 'الحي',
          value: household!.district!,
          icon: Icons.location_city_outlined,
        ),
      if (household?.electricityMeterNumber != null)
        _InfoItem(
          title: 'عداد الكهرباء',
          value: household!.electricityMeterNumber!,
          icon: Icons.bolt_outlined,
        ),
      if (household?.waterMeterNumber != null)
        _InfoItem(
          title: 'عداد الماء',
          value: household!.waterMeterNumber!,
          icon: Icons.water_drop_outlined,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 400.w(context);
        if (!useTwoColumns) {
          return Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h(context)),
                    child: _infoCell(context, item),
                  ),
                )
                .toList(),
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += 2) {
          rows.add(
            Row(
              children: [
                Expanded(child: _infoCell(context, items[i])),
                if (i + 1 < items.length) ...[
                  SizedBox(width: 12.w(context)),
                  Expanded(child: _infoCell(context, items[i + 1])),
                ] else
                  const Spacer(),
              ],
            ),
          );
          if (i + 2 < items.length) {
            rows.add(SizedBox(height: 10.h(context)));
          }
        }
        return Column(children: rows);
      },
    );
  }

  Widget _infoCell(BuildContext context, _InfoItem item) {
    return Container(
      padding: EdgeInsets.all(14.s(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 11.f(context),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryForest.withValues(alpha: 0.7),
                ),
                textDirection: TextDirection.rtl,
              ),
              SizedBox(width: 4.w(context)),
              Icon(
                item.icon,
                size: 14.ic(context),
                color: AppColors.primaryForest.withValues(alpha: 0.5),
              ),
            ],
          ),
          SizedBox(height: 8.h(context)),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _loadingSkeleton(BuildContext context) {
    Widget bar(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.thirdGoldenWheat.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: bar(72.h(context))),
            SizedBox(width: 12.w(context)),
            Expanded(child: bar(72.h(context))),
          ],
        ),
        SizedBox(height: 10.h(context)),
        bar(72.h(context)),
      ],
    );
  }

  Widget _errorSection(BuildContext context, String message) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 14.f(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
            height: 1.5,
          ),
        ),
        if (onRetry != null) ...[
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 44.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                backgroundColor:
                    AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                side: BorderSide(
                  color: AppColors.primaryForest.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;
}
