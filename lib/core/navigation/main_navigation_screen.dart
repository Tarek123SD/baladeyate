import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/custom_bottom_navigation_bar.dart';import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isDesktop
                ? Dimensions.webMaxWidth.w(context)
                : double.infinity,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: navigationShell,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
