import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_button.dart';
import 'package:baladeyate/core/widgets/custom_donation_amount_field.dart';
import 'package:baladeyate/core/widgets/custom_receipt_upload_box.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_cubit.dart';
import 'package:baladeyate/features/donations/cubits/donate_cubit/donate_state.dart';
import 'package:baladeyate/features/donations/models/donation_model.dart';
import 'package:baladeyate/features/donations/presentation/components/donation_payment_destination_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DonationQuickDonateSection extends StatelessWidget {
  const DonationQuickDonateSection({
    super.key,
    this.sectionKey,
    required this.amounts,
    required this.selectedAmount,
    required this.customController,
    required this.selectedCase,
    required this.receiptImage,
    required this.effectiveAmount,
    required this.onAmountSelected,
    required this.onCustomChanged,
    required this.onReceiptPicked,
    required this.onReceiptRemoved,
    required this.onClearSelectedCase,
    required this.onDonateSuccess,
  });

  final Key? sectionKey;
  final List<int> amounts;
  final int? selectedAmount;
  final TextEditingController customController;
  final DonationModel? selectedCase;
  final File? receiptImage;
  final int effectiveAmount;
  final ValueChanged<int> onAmountSelected;
  final ValueChanged<String> onCustomChanged;
  final ValueChanged<File> onReceiptPicked;
  final VoidCallback onReceiptRemoved;
  final VoidCallback onClearSelectedCase;
  final VoidCallback onDonateSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DonateCubit, DonateState>(
      listener: (context, state) {
        if (state is DonateSuccess) {
          onDonateSuccess();
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
        final isEnabled =
            effectiveAmount > 0 && receiptImage != null && !isLoading;

        return Container(
          key: sectionKey,
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
              if (selectedCase != null) ...[
                SizedBox(height: 12.h(context)),
                DonationSelectedCaseTag(
                  title: selectedCase!.title,
                  onClear: onClearSelectedCase,
                ),
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
                    children: amounts
                        .map(
                          (amount) => CustomDonationAmountButton(
                            amount: amount,
                            width: width,
                            isSelected: selectedAmount == amount &&
                                customController.text.trim().isEmpty,
                            onTap: () => onAmountSelected(amount),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              SizedBox(height: 18.h(context)),
              CustomDonationAmountField(
                controller: customController,
                onChanged: onCustomChanged,
              ),
              if (selectedCase?.hasPaymentDestination == true) ...[
                SizedBox(height: 20.h(context)),
                DonationPaymentDestinationCard(donation: selectedCase!),
              ],
              SizedBox(height: 20.h(context)),
              CustomReceiptUploadBox(
                selectedImage: receiptImage,
                onImagePicked: onReceiptPicked,
                onImageRemoved: onReceiptRemoved,
              ),
              SizedBox(height: 20.h(context)),
              DonationSummaryRow(amount: effectiveAmount),
              SizedBox(height: 20.h(context)),
              SizedBox(
                width: double.infinity,
                height: 52.h(context),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading || isEnabled
                        ? AppColors.primaryForest
                        : Colors.grey.shade300,
                    disabledBackgroundColor: isLoading
                        ? AppColors.primaryForest.withValues(alpha: 0.7)
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
                                id: selectedCase?.id ?? 1,
                                amount: effectiveAmount,
                                receiptImage: receiptImage,
                              );
                        }
                      : null,
                  icon: isLoading
                      ? const SizedBox.shrink()
                      : Icon(
                          AppIcons.donateActive,
                          color: Colors.white,
                          size: 20.ic(context),
                        ),
                  label: isLoading
                      ? SizedBox(
                          width: 22.w(context),
                          height: 22.w(context),
                          child: CircularProgressIndicator(
                            color: AppColors.contrastingProgress(
                              AppColors.primaryForest,
                            ),
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
}

class DonationSelectedCaseTag extends StatelessWidget {
  const DonationSelectedCaseTag({
    super.key,
    required this.title,
    required this.onClear,
  });

  final String title;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
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
            AppIcons.announcements,
            size: 16.ic(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(width: 6.w(context)),
          Flexible(
            child: Text(
              'الحملة: $title',
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
            onTap: onClear,
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
}

class DonationSummaryRow extends StatelessWidget {
  const DonationSummaryRow({
    super.key,
    required this.amount,
  });

  final int amount;

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r"\B(?=(\d{3})+(?!\d))"),
          (match) => ",",
        );
  }

  @override
  Widget build(BuildContext context) {
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
