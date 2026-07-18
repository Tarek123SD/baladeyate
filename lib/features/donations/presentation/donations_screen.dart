import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_donation_campaign_card.dart';
import 'package:baladeyate/core/widgets/custom_donation_statistic_card.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donations_cubit/donations_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> {
  static const List<int> _amounts = [25000, 10000, 100000, 50000];

  final TextEditingController _customController = TextEditingController();
  final GlobalKey _amountSectionKey = GlobalKey();

  int? _selectedAmount;
  String? _selectedCampaign;

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

  void _selectCampaign(String title) {
    setState(() => _selectedCampaign = title);
    final keyContext = _amountSectionKey.currentContext;
    if (keyContext != null) {
      Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r"\B(?=(\d{3})+(?!\d))"),
          (match) => ",",
        );
  }

  void _confirmDonation() {
    final amount = _effectiveAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد قيمة التبرع أولاً')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    _showSuccessSheet(amount);
  }

  void _showSuccessSheet(int amount) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r(context))),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24.w(context),
              16.h(context),
              24.w(context),
              24.h(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42.w(context),
                    height: 4.h(context),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 20.h(context)),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(18.s(context)),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: AppColors.green,
                      size: 40.ic(context),
                    ),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                Text(
                  'شكراً لكرمك!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 20.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  _selectedCampaign == null
                      ? 'أنت على وشك التبرع بمبلغ ${_formatNumber(amount)} ل.س.'
                      : 'أنت على وشك التبرع بمبلغ ${_formatNumber(amount)} ل.س لحملة "$_selectedCampaign".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryCharcoal,
                    fontSize: 14.f(context),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24.h(context)),
                SizedBox(
                  width: double.infinity,
                  height: 52.h(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r(context)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _resetSelection();
                    },
                    child: Text(
                      'إتمام التبرع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h(context)),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  child: Text(
                    'تعديل المبلغ',
                    style: TextStyle(
                      color: AppColors.secondaryCharcoal,
                      fontSize: 14.f(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedAmount = null;
      _selectedCampaign = null;
      _customController.clear();
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل تبرعك بنجاح. شكراً لدعمك!'),
        backgroundColor: AppColors.green,
      ),
    );
  }

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
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 18.h(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFeaturedCampaignCard(context),
                      SizedBox(height: 28.h(context)),
                      _buildStatsGrid(context),
                      SizedBox(height: 28.h(context)),
                      const _SectionHeader(
                        title: 'الحملات النشطة',
                        actionLabel: 'عرض الكل',
                      ),
                      SizedBox(height: 18.h(context)),
                      _buildCampaignsSection(context),
                      SizedBox(height: 28.h(context)),
                      _buildAmountSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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
                  onDonate: () => _selectCampaign(cases[i].title),
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
      padding: EdgeInsets.symmetric(vertical: 36.h(context), horizontal: 20.w(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
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
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
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
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.thirdGoldenWheat.withValues(alpha: 0.8),
        ),
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
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 44.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                backgroundColor:
                    AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                side: BorderSide(
                  color: AppColors.primaryForest.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    return Container(
      key: _amountSectionKey,
      padding: EdgeInsets.all(18.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 5.w(context),
                height: 22.h(context),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(4.r(context)),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Expanded(
                child: Text(
                  'حدد قيمة التبرع',
                  textAlign: TextAlign.right,
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
            'اختر المبلغ الذي ترغب في المساعدة به',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.8),
              fontSize: 13.f(context),
            ),
          ),
          if (_selectedCampaign != null) ...[
            SizedBox(height: 10.h(context)),
            _buildCampaignTargetChip(context),
          ],
          SizedBox(height: 18.h(context)),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
              final spacing = 12.w(context);
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
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
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420.w(context)),
              child: CustomDonationAmountField(
                controller: _customController,
                onChanged: _onCustomChanged,
              ),
            ),
          ),
          SizedBox(height: 20.h(context)),
          _buildSummaryRow(context),
          SizedBox(height: 18.h(context)),
          SizedBox(
            width: double.infinity,
            height: 56.h(context),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _effectiveAmount > 0 ? AppColors.green : Colors.grey,
                disabledBackgroundColor:
                    AppColors.secondaryCharcoal.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r(context)),
                ),
              ),
              onPressed: _effectiveAmount > 0 ? _confirmDonation : null,
              icon: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 20.ic(context),
              ),
              label: Text(
                'تأكيد التبرع والمتابعة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignTargetChip(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 8.h(context),
        ),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.r(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_rounded,
              size: 16.ic(context),
              color: AppColors.green,
            ),
            SizedBox(width: 6.w(context)),
            Flexible(
              child: Text(
                'الحملة: $_selectedCampaign',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 12.f(context),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4.w(context)),
            GestureDetector(
              onTap: () => setState(() => _selectedCampaign = null),
              child: Icon(
                Icons.close_rounded,
                size: 16.ic(context),
                color: AppColors.green,
              ),
            ),
          ],
        ),
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
        color: AppColors.primaryForest.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'إجمالي التبرع',
            style: TextStyle(
              color: AppColors.secondaryCharcoal,
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            amount > 0 ? '${_formatNumber(amount)} ل.س' : '— ل.س',
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 18.f(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatsGrid(BuildContext context) {
    const stats = <({String value, String label})>[
      (value: '89K', label: 'متبرع نشط'),
      (value: '+145', label: 'مشروع مدعوم'),
      (value: '24/7', label: 'خدمة كاملة'),
      (value: '12', label: 'محافظة مستفيدة'),
    ];

    final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
    final spacing = 16.w(context);
    final rows = <Widget>[];

    for (var i = 0; i < stats.length; i += columns) {
      final rowItems = stats.skip(i).take(columns).toList();
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
          if (i > 0) SizedBox(height: 16.h(context)),
          rows[i],
        ],
      ],
    );
  }

  Widget _buildFeaturedCampaignCard(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final radius = 28.r(context);

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
            color: AppColors.primaryForest.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
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
              padding: EdgeInsets.all(isMobile ? 20.s(context) : 24.s(context)),
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
                  SizedBox(height: 18.h(context)),
                  Text(
                    'إعادة إعمار المدارس التاريخية',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 22.f(context) : 26.f(context),
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h(context)),
                  Text(
                    'ساهم في ترميم الصروح التعليمية التي تعيد بناء التاريخ وتضمن مستقبلاً مشرقاً لأجيالنا القادمة.',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14.f(context),
                      height: 1.7,
                    ),
                  ),
                  SizedBox(height: 22.h(context)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: isMobile ? double.infinity : 180.w(context),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGoldenWheat,
                          foregroundColor: AppColors.primaryForest,
                          padding: EdgeInsets.symmetric(
                            vertical: 14.h(context),
                            horizontal: 16.w(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r(context)),
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18.ic(context),
                        ),
                        label: Text(
                          'تصدق الآن',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.f(context),
                          ),
                        ),
                        onPressed: () =>
                            _selectCampaign('إعادة إعمار المدارس التاريخية'),
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
          width: 5.w(context),
          height: 22.h(context),
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(4.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
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
            borderRadius: BorderRadius.circular(20.r(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.w700,
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
