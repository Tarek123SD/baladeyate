import 'package:flutter/material.dart';
import 'package:baladeyate/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final radius = 20.r(context);
    final iconSize = 22.s(context);
    final selectedFont = 11.s(context);
    final unselectedFont = 10.s(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: navigationShell,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        child: BottomNavigationBar(
          iconSize: iconSize,
          selectedFontSize: selectedFont,
          unselectedFontSize: unselectedFont,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.secondaryForest,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: iconSize),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: iconSize),
              label: l10n.navProfile,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism, size: iconSize),
              label: l10n.navDonations,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_outlined, size: iconSize),
              label: l10n.navTrack,
            ),
          ],
        ),
      ),
    );
  }
}
