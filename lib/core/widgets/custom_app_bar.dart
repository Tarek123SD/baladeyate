import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final logoWidth = (250.w(context)).clamp(140.0, 320.0);
    final iconSize = 24.s(context);

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Row(
        textDirection: TextDirection.rtl,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: logoWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r(context)),
              child: Image.asset(
                'assets/images/Syrian_horizontal_dark_green.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Row(
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
