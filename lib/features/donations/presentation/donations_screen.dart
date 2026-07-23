import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_donation_campaign_card.dart';
import 'package:baladeyate/core/widgets/custom_donation_statistic_card.dart';
import 'package:baladeyate/core/widgets/custom_receipt_upload_box.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_state.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
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

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r"\B(?=(\d{3})+(?!\d))"),
          (match) => ",",
        );
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 18.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hero Card (Featured Campaign)
                        _buildHeroCard(context),
                        SizedBox(height: 24.h(context)),

                        // Stats Grid (Stateless Widget)
                        const _DonationStatsGrid(),
                        SizedBox(height: 28.h(context)),

                        // Active Campaigns Section
                        const _SectionHeader(
                          title: 'الحملات النشطة',
                          actionLabel: 'عرض الكل',
                        ),
                        SizedBox(height: 16.h(context)),
                        _buildCampaignsSection(context),
                        SizedBox(height: 28.h(context)),

                        // Quick Payment / Amount Section
                        _buildAmountSection(context),
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

  Widget _buildHeroCard(BuildContext context) {
    return BlocBuilder<DonationsCubit, DonationsState>(
      builder: (context, state) {
        DonationModel? featuredCampaign;
        if (state is DonationsLoaded && state.cases.isNotEmpty) {
          featuredCampaign = state.cases.first;
        }

        final title = featuredCampaign?.title ?? 'إعادة إعمار المدارس التاريخية';
        final description = featuredCampaign?.description.isNotEmpty == true
            ? featuredCampaign!.description
            : 'ساهم في ترميم الصروح التعليمية التي تعيد بناء التاريخ وتضمن مستقبلاً مشرقاً لأجيالنا القادمة.';

        final isMobile = ResponsiveHelper.isMobile(context);
        final radius = 24.r(context);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppColors.primaryForest,
                AppColors.secondaryForest,
                AppColors.thirdForest,
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryForest.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              children: [
                Positioned(
                  top: -30.s(context),
                  left: -20.s(context),
                  child: _decorCircle(context, 120.s(context), 0.08),
                ),
                Positioned(
                  bottom: -40.s(context),
                  left: 40.s(context),
                  child: _decorCircle(context, 90.s(context), 0.06),
                ),
                Padding(
                  padding:
                      EdgeInsets.all(isMobile ? 20.s(context) : 24.s(context)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w(context),
                            vertical: 6.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(18.r(context)),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Text(
                            'حملة مميزة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.f(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h(context)),
                      Text(
                        title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 22.f(context) : 26.f(context),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 10.h(context)),
                      Text(
                        description,
                        textAlign: TextAlign.right,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 13.5.f(context),
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 20.h(context)),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: isMobile ? double.infinity : 180.w(context),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryForest,
                              elevation: 3,
                              padding: EdgeInsets.symmetric(
                                vertical: 14.h(context),
                                horizontal: 20.w(context),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(28.r(context)),
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16.ic(context),
                              color: AppColors.primaryForest,
                            ),
                            label: Text(
                              'تصدق الآن',
                              style: TextStyle(
                                color: AppColors.primaryForest,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5.f(context),
                              ),
                            ),
                            onPressed: () => _navigateToPayment(
                              featuredCampaign ?? title,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _decorCircle(BuildContext context, double size, double alpha) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCampaignsSection(BuildContext context) {
    return BlocBuilder<DonationsCubit, DonationsState>(
      builder: (context, state) {
        if (state is DonationsLoading || state is DonationsInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h(context)),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryForest),
            ),
          );
        }

        if (state is DonationsFailure) {
          return _buildErrorBox(
            context,
            message: state.message,
            onRetry: () => context.read<DonationsCubit>().loadCases(),
          );
        }

        if (state is DonationsLoaded) {
          final cases = state.cases;
          if (cases.isEmpty) {
            return _buildEmptyBox(context);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cases.length; i++) ...[
                if (i > 0) SizedBox(height: 16.h(context)),
                CustomDonationCampaignCard(
                  label: cases[i].categoryLabel,
                  title: cases[i].title,
                  subtitle: cases[i].description,
                  progress: cases[i].progress,
                  statusLabel: cases[i].statusLabel,
                  goalLabel: cases[i].goalLabel,
                  icon: cases[i].categoryIcon,
                  iconColor: cases[i].categoryColor,
                  onDonate: () => _navigateToPayment(cases[i]),
                ),
              ],
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 32.h(context),
        horizontal: 20.w(context),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.volunteer_activism_rounded,
            size: 40.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 12.h(context)),
          Text(
            'لا توجد حملات نشطة حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 6.h(context)),
          Text(
            'سيتم عرض الحملات هنا بمجرد إضافتها من لوحة التحكم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5.f(context),
              color: const Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBox(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 30.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 10.h(context)),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 42.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                side: const BorderSide(color: AppColors.primaryForest),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 13.5.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return BlocConsumer<DonateCubit, DonateState>(
      listener: (context, state) {
        if (state is DonateSuccess) {
          _customController.clear();
          setState(() {
            _selectedAmount = 25000;
            _selectedCase = null;
            _receiptImage = null;
          });
          AppSnackBar.showSuccess(
            context,
            'تم استلام تبرعك بنجاح، شكراً لعطائك',
          );
        } else if (state is DonateFailure) {
          AppSnackBar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is DonateLoading;
        final isEnabled = _effectiveAmount > 0 && _receiptImage != null && !isLoading;

        return Container(
          key: _amountSectionKey,
          padding: EdgeInsets.all(20.s(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r(context)),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w(context),
                    height: 20.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest,
                      borderRadius: BorderRadius.circular(4.r(context)),
                    ),
                  ),
                  SizedBox(width: 8.w(context)),
                  Expanded(
                    child: Text(
                      'تبرع سريع',
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 18.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h(context)),
              Text(
                'اختر قيمة التبرع وأرفق صورة الإيصال للخصم الفوري',
                style: TextStyle(
                  color: const Color(0xFF757575),
                  fontSize: 13.f(context),
                ),
              ),
              if (_selectedCase != null) ...[
                SizedBox(height: 12.h(context)),
                _buildSelectedCaseTag(context),
              ],
              SizedBox(height: 18.h(context)),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
                  final spacing = 12.w(context);
                  final width =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                          columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: _amounts
                        .map(
                          (amount) => CustomDonationAmountButton(
                            amount: amount,
                            width: width,
                            isSelected: _selectedAmount == amount &&
                                _customController.text.trim().isEmpty,
                            onTap: () => _selectAmount(amount),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              SizedBox(height: 18.h(context)),
              CustomDonationAmountField(
                controller: _customController,
                onChanged: _onCustomChanged,
              ),
              SizedBox(height: 20.h(context)),
              CustomReceiptUploadBox(
                selectedImage: _receiptImage,
                onImagePicked: (file) {
                  setState(() => _receiptImage = file);
                },
                onImageRemoved: () {
                  setState(() => _receiptImage = null);
                },
              ),
              SizedBox(height: 20.h(context)),
              _buildSummaryRow(context),
              SizedBox(height: 20.h(context)),
              SizedBox(
                width: double.infinity,
                height: 52.h(context),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEnabled
                        ? AppColors.primaryForest
                        : Colors.grey.shade300,
                    elevation: isEnabled ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r(context)),
                    ),
                  ),
                  onPressed: isEnabled
                      ? () {
                          FocusScope.of(context).unfocus();
                          context.read<DonateCubit>().submitDonation(
                                id: _selectedCase?.id ?? 1,
                                amount: _effectiveAmount,
                                receiptImage: _receiptImage,
                              );
                        }
                      : null,
                  icon: isLoading
                      ? const SizedBox.shrink()
                      : Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 20.ic(context),
                        ),
                  label: isLoading
                      ? SizedBox(
                          width: 22.w(context),
                          height: 22.w(context),
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'تأكيد التبرع',
                          style: TextStyle(
                            color: isEnabled
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: 16.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedCaseTag(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w(context),
        vertical: 8.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.campaign_rounded,
            size: 16.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(width: 6.w(context)),
          Flexible(
            child: Text(
              'الحملة: ${_selectedCase?.title}',
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 12.f(context),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6.w(context)),
          GestureDetector(
            onTap: () => setState(() => _selectedCase = null),
            child: Icon(
              Icons.close_rounded,
              size: 16.ic(context),
              color: AppColors.primaryForest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final amount = _effectiveAmount;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 14.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            'إجمالي التبرع',
            style: TextStyle(
              color: const Color(0xFF424242),
              fontSize: 14.f(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            amount > 0 ? '${_formatNumber(amount)} ل.س' : '0 ل.س',
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone StatelessWidget for the Stats Grid
class _DonationStatsGrid extends StatelessWidget {
  const _DonationStatsGrid();

  static const _stats = <({String value, String label, IconData icon})>[
    (
      value: '89K',
      label: 'متبرع نشط',
      icon: Icons.people_alt_rounded,
    ),
    (
      value: '+145',
      label: 'مشروع مدعوم',
      icon: Icons.volunteer_activism_rounded,
    ),
    (
      value: '24/7',
      label: 'خدمة كاملة',
      icon: Icons.support_agent_rounded,
    ),
    (
      value: '12',
      label: 'محافظة مستفيدة',
      icon: Icons.location_city_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
    final spacing = 14.w(context);
    final rows = <Widget>[];

    for (var i = 0; i < _stats.length; i += columns) {
      final rowItems = _stats.skip(i).take(columns).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < columns; j++) ...[
                if (j > 0) SizedBox(width: spacing),
                Expanded(
                  child: j < rowItems.length
                      ? CustomDonationStatisticCard(
                          value: rowItems[j].value,
                          label: rowItems[j].label,
                          icon: rowItems[j].icon,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: 14.h(context)),
          rows[i],
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
  });

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w(context),
          height: 18.h(context),
          decoration: BoxDecoration(
            color: AppColors.primaryForest,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 12.w(context)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w(context),
            vertical: 6.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryForest.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontSize: 12.5.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 4.w(context)),
              Icon(
                Icons.chevron_left_rounded,
                size: 18.ic(context),
                color: AppColors.primaryForest,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
