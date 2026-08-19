import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/cemetery_map/models/grave_model.dart';
import 'package:baladeyate/features/cemetery_map/presentation/components/grave_details_sheet.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for citizens — reserve an available grave.
class CitizenGraveDetailsSheet extends StatelessWidget {
  const CitizenGraveDetailsSheet({
    super.key,
    required this.grave,
    required this.onReserve,
  });

  final GraveModel grave;
  final VoidCallback onReserve;

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                const SizedBox(height: 16),
                Text(
                  'قبر ${grave.id}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryForest,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الحالة: ${graveStatusLabel(grave.status)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: grave.isAvailable ? onReserve : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'طلب حجز هذا القبر',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
