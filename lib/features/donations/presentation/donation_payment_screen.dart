import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_receipt_upload_box.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_state.dart';
import 'package:baladeyate/features/donations/models/donation_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationPaymentScreen extends StatefulWidget {
  const DonationPaymentScreen({
    super.key,
    this.donationCase,
    this.campaignTitle,
    this.campaignId,
  });

  final DonationCase? donationCase;
  final String? campaignTitle;
  final int? campaignId;

  @override
  State<DonationPaymentScreen> createState() => _DonationPaymentScreenState();
}

class _DonationPaymentScreenState extends State<DonationPaymentScreen> {
  static const List<int> _presetAmounts = [10000, 25000, 50000, 100000];

  final TextEditingController _customController = TextEditingController();
  int? _selectedAmount = 25000;
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

  void _onCustomAmountChanged(String value) {
    setState(() {
      if (value.trim().isNotEmpty) {
        _selectedAmount = null;
      }
    });
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r"\B(?=(\d{3})+(?!\d))"),
          (match) => ",",
        );
  }

  void _onConfirmPressed(BuildContext context) {
    final amount = _effectiveAmount;
    if (amount <= 0) {
      AppSnackBar.showError(context, 'يرجى تحديد قيمة التبرع أولاً');
      return;
    }

    if (_receiptImage == null) {
      AppSnackBar.showError(context, 'يرجى إرفاق صورة إيصال التحويل/الدفع أولاً');
      return;
    }

    final targetId = widget.donationCase?.id ?? widget.campaignId ?? 1;
    FocusScope.of(context).unfocus();
    context.read<DonateCubit>().submitDonation(
          id: targetId,
          amount: amount,
          receiptImage: _receiptImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final maxContentWidth = ResponsiveHelper.contentMaxWidth(context);

    final title = widget.donationCase?.title ??
        widget.campaignTitle ??
        'تبرع عام لخدمات البلدية';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(showBackButton: true),
        body: SafeArea(
          child: BlocConsumer<DonateCubit, DonateState>(
            listener: (context, state) {
              if (state is DonateSuccess) {
                Navigator.of(context).pop(true);
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

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20.h(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campaign Header Card
                        _buildCampaignHeader(context, title),
                        SizedBox(height: 24.h(context)),

                        // Amount Selection Grid Section
                        _buildSectionTitle(context, 'اختر قيمة التبرع'),
                        SizedBox(height: 14.h(context)),
                        _buildAmountGrid(context),
                        SizedBox(height: 20.h(context)),

                        // Custom Amount TextField
                        CustomDonationAmountField(
                          controller: _customController,
                          onChanged: _onCustomAmountChanged,
                        ),
                        SizedBox(height: 24.h(context)),

                        // Receipt Image Attachment Box
                        CustomReceiptUploadBox(
                          selectedImage: _receiptImage,
                          onImagePicked: (file) {
                            setState(() => _receiptImage = file);
                          },
                          onImageRemoved: () {
                            setState(() => _receiptImage = null);
                          },
                        ),
                        SizedBox(height: 28.h(context)),

                        // Total & Summary Row
                        _buildTotalRow(context),
                        SizedBox(height: 24.h(context)),

                        // Submit Button
                        _buildSubmitButton(context, isLoading),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCampaignHeader(BuildContext context, String title) {
    return Container(
      padding: EdgeInsets.all(18.s(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryForest.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(
          color: AppColors.primaryForest.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.s(context)),
            decoration: BoxDecoration(
              color: AppColors.primaryForest,
              borderRadius: BorderRadius.circular(14.r(context)),
            ),
            child: Icon(
              AppIcons.donate,
              color: Colors.white,
              size: 24.ic(context),
            ),
          ),
          SizedBox(width: 14.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الحملة المستهدفة',
                  style: TextStyle(
                    color: AppColors.primaryForest.withValues(alpha: 0.7),
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryForest,
                    fontSize: 15.5.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
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
        Text(
          text,
          style: TextStyle(
            color: AppColors.primaryForest,
            fontSize: 16.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ResponsiveHelper.isMobile(context) ? 2 : 4;
        final spacing = 12.w(context);
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _presetAmounts
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
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final amount = _effectiveAmount;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 18.w(context),
        vertical: 16.h(context),
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(
            'إجمالي التبرع',
            style: TextStyle(
              color: const Color(0xFF424242),
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            amount > 0 ? '${_formatNumber(amount)} ل.س' : '0 ل.س',
            style: TextStyle(
              color: AppColors.primaryForest,
              fontSize: 20.f(context),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isLoading) {
    final isEnabled = _effectiveAmount > 0 && _receiptImage != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 54.h(context),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isEnabled ? AppColors.primaryForest : Colors.grey.shade300,
          elevation: isEnabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r(context)),
          ),
        ),
        onPressed: isEnabled ? () => _onConfirmPressed(context) : null,
        child: isLoading
            ? SizedBox(
                width: 24.w(context),
                height: 24.w(context),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'تأكيد التبرع',
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey.shade600,
                  fontSize: 16.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
