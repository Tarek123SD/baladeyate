import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_campaigns_section.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_hero_card.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_section_header.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationsScreen extends StatelessWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final maxContentWidth = ResponsiveHelper.contentMaxWidth(context);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<DonationsCubit>().fetchDonations();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 18.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DonationHeroCard(
                          onDonate: (extra) =>
                              context.push('/donations/pay', extra: extra),
                        ),
                        SizedBox(height: 24.h(context)),
                        const DonationStatsGrid(),
                        SizedBox(height: 28.h(context)),
                        const DonationSectionHeader(
                          title: 'الحملات النشطة',
                          actionLabel: 'عرض الكل',
                        ),
                        SizedBox(height: 16.h(context)),
                        DonationCampaignsSection(
                          onDonate: (donationCase) => context.push(
                            '/donations/pay',
                            extra: donationCase,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
