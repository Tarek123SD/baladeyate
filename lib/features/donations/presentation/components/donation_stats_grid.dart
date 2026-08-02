import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_donation_statistic_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationStatsGrid extends StatelessWidget {
  const DonationStatsGrid({super.key});

  static const _stats = <({String value, String label, IconData icon})>[
    (
      value: '89K',
      label: 'متبرع نشط',
      icon: AppIcons.people,
    ),
    (
      value: '+145',
      label: 'مشروع مدعوم',
      icon: AppIcons.donateActive,
    ),
    (
      value: '24/7',
      label: 'خدمة كاملة',
      icon: AppIcons.support,
    ),
    (
      value: '12',
      label: 'محافظة مستفيدة',
      icon: AppIcons.city,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
    final spacing = 14.w(context);
    final rows = <Widget>[];

    for (var i = 0; i < _stats.length; i += columns) {
      final rowItems = _stats.skip(i).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(
                  child: j < rowItems.length
                      ? CustomDonationStatisticCard(
                          value: rowItems[j].value,
                          label: rowItems[j].label,
                          icon: rowItems[j].icon,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: 14.h(context)),
          rows[i],
        ],
      ],
    );
  }
}
