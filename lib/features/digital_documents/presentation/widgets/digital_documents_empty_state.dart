import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Clean Empty State for Digital Documents Wallet
class DigitalDocumentsEmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback? onSubmitNewTransaction;

  const DigitalDocumentsEmptyState({
    super.key,
    required this.onRefresh,
    this.onSubmitNewTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 24.w(context),
          vertical: 50.h(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Centered Wallet Icon inside circular container
            Container(
              width: 100.s(context),
              height: 100.s(context),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryForest.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.primaryForest.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.wallet_rounded,
                  size: 48.ic(context),
                  color: AppColors.primaryForest,
                ),
              ),
            ).animate().scale(duration: 350.ms, curve: Curves.easeOutBack),

            SizedBox(height: 20.h(context)),

            // Empty State Title
            Text(
              'لا تملك وثائق رقمية معتمدة حتى الآن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.f(context),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryCharcoal,
              ),
            ).animate().fadeIn(delay: 100.ms),

            SizedBox(height: 8.h(context)),

            // Subtitle Description
            Text(
              'تظهر هنا المعاملات البلدية والتراخيص الرسمية الخاصة بك حال اعتمادها وقبولها رسمياً.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5.f(context),
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ).animate().fadeIn(delay: 200.ms),

            SizedBox(height: 24.h(context)),

            // Action Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12.w(context),
              runSpacing: 12.h(context),
              children: [
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 16.ic(context),
                    color: primaryColor,
                  ),
                  label: Text(
                    'تحديث المحفظة',
                    style: TextStyle(
                      fontSize: 12.5.f(context),
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryColor, width: 1.2),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w(context),
                      vertical: 10.h(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r(context)),
                    ),
                  ),
                ),
                if (onSubmitNewTransaction != null)
                  ElevatedButton.icon(
                    onPressed: onSubmitNewTransaction,
                    icon: Icon(
                      Icons.add_task_rounded,
                      size: 16.ic(context),
                      color: Colors.white,
                    ),
                    label: Text(
                      'تقديم معاملة جديدة',
                      style: TextStyle(
                        fontSize: 12.5.f(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w(context),
                        vertical: 10.h(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r(context)),
                      ),
                      elevation: 1,
                    ),
                  ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
