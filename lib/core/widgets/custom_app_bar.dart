import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.showSettings = true,
    this.showBackButton = false,
  });

  final bool showSettings;
  final bool showBackButton;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final iconSize = 24.s(context);
    final logoWidth = (220.w(context)).clamp(120.0, 260.0);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Row(
        textDirection: TextDirection.rtl,
        children: [
          if (showBackButton)
            IconButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/main');
                }
              },
              icon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryForest,
                size: 20.s(context),
              ),
              padding: EdgeInsets.zero,
            ),
          SizedBox(
            width: logoWidth,
            height: kToolbarHeight - 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r(context)),
              child: Image.asset(
                AppAssets.logoHorizontalDarkGreen,
                fit: BoxFit.contain,
                alignment: Alignment.centerRight,
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  context.push('/notifications');
                },
                icon: Icon(
                  Icons.notifications_none,
                  color: Colors.black87,
                  size: iconSize,
                ),
                padding: EdgeInsets.zero,
              ),
              if (showSettings)
                IconButton(
                  onPressed: () {
                    context.push('/settings');
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.black87,
                    size: iconSize,
                  ),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
