import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';

/// Patterned-background shell used by password-reset flow screens.
class AuthFlowScaffold extends StatelessWidget {
  const AuthFlowScaffold({
    super.key,
    required this.body,
  });

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAssets.backgroundWhite),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(child: body),
        ),
      ],
    );
  }
}
