import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/dimensions.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/app_background.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/settings/data/privacy_policy_data.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          showSettings: false,
          showBackButton: true,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Dimensions.contentMaxWidth.w(context),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  16.h(context),
                  horizontalPadding,
                  24.h(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      PrivacyPolicyData.title,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primaryForest,
                            fontWeight: FontWeight.w700,
                            fontSize: 26.f(context),
                          ),
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      PrivacyPolicyData.lastUpdated,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondaryCharcoal
                                .withValues(alpha: 0.7),
                            fontSize: 13.f(context),
                          ),
                    ),
                    SizedBox(height: 20.h(context)),
                    _PrivacyCard(
                      child: Text(
                        PrivacyPolicyData.intro,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondaryCharcoal,
                              height: 1.7,
                              fontSize: 14.f(context),
                            ),
                      ),
                    ),
                    SizedBox(height: 12.h(context)),
                    for (final section in PrivacyPolicyData.sections) ...[
                      _PrivacyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              section.title,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.primaryForest,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.f(context),
                                  ),
                            ),
                            SizedBox(height: 8.h(context)),
                            Text(
                              section.body,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.secondaryCharcoal,
                                    height: 1.7,
                                    fontSize: 14.f(context),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h(context)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 16.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
        ),
      ),
      child: child,
    );
  }
}
