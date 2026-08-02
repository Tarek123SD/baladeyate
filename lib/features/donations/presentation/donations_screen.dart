import 'dart:io';

import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_campaigns_section.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_hero_card.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_quick_donate_section.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_section_header.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_stats_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  static const List<int> _amounts = [10000, 25000, 50000, 100000];

  final TextEditingController _customController = TextEditingController();
  final GlobalKey _amountSectionKey = GlobalKey();

  int? _selectedAmount = 25000;
  DonationModel? _selectedCase;
  File? _receiptImage;

  int get _effectiveAmount {
    final custom = int.tryParse(_customController.text.trim());
    if (custom != null && custom > 0) return custom;
    return _selectedAmount ?? 0;
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _customController.clear();
    });
  }

  void _onCustomChanged(String value) {
    setState(() {
      if (value.trim().isNotEmpty) _selectedAmount = null;
    });
  }

  void _navigateToPayment([Object? extra]) {
    context.push('/donations/pay', extra: extra);
  }

  void _onDonateSuccess() {
    _customController.clear();
    setState(() {
      _selectedAmount = 25000;
      _selectedCase = null;
      _receiptImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final maxContentWidth = ResponsiveHelper.contentMaxWidth(context);

    return BlocProvider(
      create: (_) => sl<DonateCubit>(),
      child: Container(
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
                          DonationHeroCard(onDonate: _navigateToPayment),
                          SizedBox(height: 24.h(context)),
                          const DonationStatsGrid(),
                          SizedBox(height: 28.h(context)),
                          const DonationSectionHeader(
                            title: 'الحملات النشطة',
                            actionLabel: 'عرض الكل',
                          ),
                          SizedBox(height: 16.h(context)),
                          DonationCampaignsSection(
                            onDonate: _navigateToPayment,
                          ),
                          SizedBox(height: 28.h(context)),
                          DonationQuickDonateSection(
                            sectionKey: _amountSectionKey,
                            amounts: _amounts,
                            selectedAmount: _selectedAmount,
                            customController: _customController,
                            selectedCase: _selectedCase,
                            receiptImage: _receiptImage,
                            effectiveAmount: _effectiveAmount,
                            onAmountSelected: _selectAmount,
                            onCustomChanged: _onCustomChanged,
                            onReceiptPicked: (file) {
                              setState(() => _receiptImage = file);
                            },
                            onReceiptRemoved: () {
                              setState(() => _receiptImage = null);
                            },
                            onClearSelectedCase: () {
                              setState(() => _selectedCase = null);
                            },
                            onDonateSuccess: _onDonateSuccess,
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
      ),
    );
  }
}
