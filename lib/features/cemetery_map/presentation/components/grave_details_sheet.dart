import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:flutter/material.dart';

String graveStatusLabel(String status) {
  return switch (status) {
    'available' => 'متاح',
    'occupied' => 'مشغول',
    'booked' => 'محجوز',
    'reserved' => 'محجوز',
    _ => status,
  };
}

/// Bottom sheet showing status and optional deceased name for a grave.
class GraveDetailsSheet extends StatelessWidget {
  const GraveDetailsSheet({
    super.key,
    required this.grave,
    this.deceasedName,
  });

  final GraveModel grave;
  final String? deceasedName;

  String get _statusLabel => graveStatusLabel(grave.status);

  Color get _statusColor {
    return switch (grave.status) {
      'available' => AppColors.primaryForest,
      'occupied' => const Color(0xFF8B1A1A),
      'booked' => const Color(0xFF8B6914),
      'reserved' => const Color(0xFF8B6914),
      _ => AppColors.secondaryCharcoal,
    };
  }

  IconData get _statusIcon {
    return switch (grave.status) {
      'available' => AppIcons.plotAvailable,
      'occupied' => AppIcons.plotOccupied,
      'booked' => AppIcons.plotBooked,
      'reserved' => AppIcons.plotBooked,
      _ => AppIcons.plotInfo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_statusIcon, color: _statusColor, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'قبر ${grave.id}',
                            style: const TextStyle(
                              color: AppColors.primaryForest,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تفاصيل موقع القبر على الخريطة',
                            style: TextStyle(
                              color: AppColors.secondaryCharcoal
                                  .withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.thirdGoldenWheat.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryForest.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      GraveDetailRow(
                        label: 'الحالة',
                        value: _statusLabel,
                        valueColor: _statusColor,
                        icon: _statusIcon,
                      ),
                      if (deceasedName != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color:
                                AppColors.primaryForest.withValues(alpha: 0.12),
                          ),
                        ),
                        GraveDetailRow(
                          label: 'اسم المتوفى',
                          value: deceasedName!,
                          icon: Icons.badge_outlined,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

/// Label/value row used inside [GraveDetailsSheet].
class GraveDetailRow extends StatelessWidget {
  const GraveDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (icon != null) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: valueColor ?? AppColors.primaryForest,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: valueColor ?? AppColors.primaryCharcoal,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
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
