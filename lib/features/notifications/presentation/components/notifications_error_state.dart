import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/profile/presentation/components/profile_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class NotificationsErrorState extends StatelessWidget {
  const NotificationsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProfileEmptyState(
              icon: Icons.wifi_off_rounded,
              title: 'تعذّر تحميل الإشعارات',
              description: message,
            ),
            SizedBox(height: 16.h(context)),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.w(context),
                  vertical: 12.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.ic(context)),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
