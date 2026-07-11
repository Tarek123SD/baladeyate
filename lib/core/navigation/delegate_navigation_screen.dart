import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const DelegateNavigationScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = context.isDesktop
              ? Dimensions.webMaxWidth
                  .w(context)
                  .clamp(0.0, constraints.maxWidth)
                  .toDouble()
              : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              height: constraints.maxHeight,
              child: navigationShell,
            ),
          );
        },
      ),
      bottomNavigationBar: DelegateBottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: navigationShell.goBranch,
      ),
    );
  }
}
