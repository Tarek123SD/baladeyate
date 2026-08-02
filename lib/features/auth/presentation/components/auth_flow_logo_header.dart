import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Centered logo + brand title used across password-reset flow screens.
class AuthFlowLogoHeader extends StatelessWidget {
  const AuthFlowLogoHeader({
    super.key,
    this.logoSize = 110,
  });

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          AppAssets.logoGold,
          width: logoSize.s(context),
          height: logoSize.s(context),
        ),
        SizedBox(height: 20.h(context)),
        Text(
          'بلديتي',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 6.h(context)),
        Text(
          'الجمهورية العربية السورية',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}
