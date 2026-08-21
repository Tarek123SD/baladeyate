import 'package:baladeyate/core/navigation/delegate_nav_destinations.dart';
import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final path = GoRouterState.of(context).uri.path;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.fieldWorkTypes.join() !=
                  current.user.fieldWorkTypes.join() ||
              previous.user.role != current.user.role;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, authState) {
        final user = authState is AuthSuccess ? authState.user : null;
        final destinations = DelegateNavDestinations.forUser(user);
        var selectedIndex =
            destinations.indexWhere((item) => item.matchesPath(path));
        if (selectedIndex < 0) {
          selectedIndex = destinations.indexWhere(
            (item) => item.branchIndex == navigationShell.currentIndex,
          );
        }
        if (selectedIndex < 0) {
          selectedIndex = 0;
        }

        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBody: true,
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
            bottomNavigationBar: Material(
              type: MaterialType.transparency,
              child: DelegateBottomNavigationBar(
                destinations: destinations,
                selectedIndex: selectedIndex,
                onTap: (index) => _openDestination(
                  context,
                  destinations[index],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDestination(BuildContext context, DelegateNavDestination destination) {
    final path = GoRouterState.of(context).uri.path;
    if (destination.matchesPath(path)) {
      return;
    }

    if (destination.branchIndex != null) {
      if (destination.branchIndex == DelegateShellIndices.home) {
        context.go('/delegate/home');
        return;
      }
      navigationShell.goBranch(destination.branchIndex!);
      return;
    }

    final pushPath = destination.pushPath;
    if (pushPath != null) {
      context.push(pushPath);
    }
  }
}
