import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/home/presentation/components/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateHomeQuickActions extends StatelessWidget {
  const DelegateHomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final gap = 12.s(context);

    Widget tile(String title, IconData icon, VoidCallback onTap) {
      return CustomCard(
        title: title,
        icon: icon,
        bgColor: Colors.white,
        iconColor: AppColors.primaryForest,
        onTap: onTap,
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: tile(
                'الخريطة',
                AppIcons.map,
                () => context.go('/delegate/map'),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: tile(
                'المهام',
                AppIcons.tasks,
                () => context.go('/delegate/tasks'),
              ),
            ),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(
              child: tile(
                'فحص الوثائق',
                AppIcons.scanDocument,
                () => context.push('/delegate/home/verify-document'),
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: tile(
                'خريطة المقبرة',
                AppIcons.cemetery,
                () => context.push('/delegate/cemetery-map'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
