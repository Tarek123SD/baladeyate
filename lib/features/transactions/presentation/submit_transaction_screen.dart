import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/validator/validator.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';

import '../cubits/submit_transaction_cubit/submit_transaction_cubit.dart';
import '../cubits/submit_transaction_cubit/submit_transaction_state.dart';
import 'components/file_attachments_list.dart';
import 'components/file_picker_container.dart';

class SubmitTransactionScreen extends StatelessWidget {
  final int? buildingId;

  const SubmitTransactionScreen({super.key, this.buildingId});

  @override
  Widget build(BuildContext context) {
    try {
      BlocProvider.of<SubmitTransactionCubit>(context);
      return SubmitTransactionForm(buildingId: buildingId);
    } catch (_) {
      return BlocProvider(
        create: (context) => sl<SubmitTransactionCubit>(),
        child: SubmitTransactionForm(buildingId: buildingId),
      );
    }
  }
}

class SubmitTransactionForm extends StatefulWidget {
  final int? buildingId;

  const SubmitTransactionForm({super.key, this.buildingId});

  @override
  State<SubmitTransactionForm> createState() => _SubmitTransactionFormState();
}

class _SubmitTransactionFormState extends State<SubmitTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedTypeDisplay;
  final Map<String, String> _transactionTypes = {
    'رخصة تجارية': 'commercial_license',
    'تصريح بناء': 'building_permit',
  };

  final _shopAreaController = TextEditingController();
  final _activityTypeController = TextEditingController();

  @override
  void dispose() {
    _shopAreaController.dispose();
    _activityTypeController.dispose();
    super.dispose();
  }

  void _resetForm(BuildContext context) {
    _shopAreaController.clear();
    _activityTypeController.clear();
    setState(() {
      _selectedTypeDisplay = null;
    });
    context.read<SubmitTransactionCubit>().reset();
  }

  void _submit(BuildContext context) {
    if (_selectedTypeDisplay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى اختيار نوع المعاملة أولاً',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.alertRed,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<SubmitTransactionCubit>();

      // Build form data map for submission
      final Map<String, dynamic> formData = {};
      if (_transactionTypes[_selectedTypeDisplay] == 'commercial_license') {
        formData['shop_area'] = _shopAreaController.text.trim();
        formData['activity_type'] = _activityTypeController.text.trim();
      }

      cubit.submitTransaction(
        type: _transactionTypes[_selectedTypeDisplay]!,
        formData: formData,
        buildingId: widget.buildingId,
      );
    }
  }

  void _showSuccessDialog(BuildContext context, String transactionNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r(context)),
            ),
            title: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.r(context)),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 48.s(context),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                Text(
                  'تم تقديم الطلب بنجاح',
                  style: TextStyle(
                    fontSize: 18.s(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryForest,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تم تسجيل معاملتك في النظام بنجاح. يرجى الاحتفاظ برقم المعاملة لمتابعة حالة الطلب لاحقاً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.s(context),
                    color: AppColors.secondaryCharcoal,
                  ),
                ),
                SizedBox(height: 16.h(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w(context),
                    vertical: 10.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10.r(context)),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'رقم المعاملة:',
                        style: TextStyle(
                          fontSize: 13.s(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryCharcoal,
                        ),
                      ),
                      Row(
                        children: [
                          SelectableText(
                            transactionNumber,
                            style: TextStyle(
                              fontSize: 14.s(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryForest,
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          IconButton(
                            icon: Icon(
                              Icons.copy_rounded,
                              size: 18.s(context),
                              color: AppColors.primaryForest,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: transactionNumber));
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تم نسخ رقم المعاملة إلى الحافظة',
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryForest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss success dialog
                    _resetForm(context);
                    if (context.canPop()) {
                      context.pop();
                    }
                  },
                  child: Text(
                    'موافق',
                    style: TextStyle(
                      fontSize: 14.s(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubmitTransactionCubit, SubmitTransactionState>(
      listener: (context, state) {
        if (state is SubmitTransactionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.alertRed,
            ),
          );
        } else if (state is SubmitTransactionSuccess) {
          _showSuccessDialog(context, state.transactionNumber);
        }
      },
      builder: (context, state) {
        final cubit = context.read<SubmitTransactionCubit>();
        final isLoading = state is SubmitTransactionLoading;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(showBackButton: true),
            body: SafeArea(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ResponsiveBody(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormSectionCard(
                            title: 'تقديم طلب معاملة جديدة',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FormDropdownField(
                                  label: 'نوع المعاملة',
                                  items: _transactionTypes.keys.toList(),
                                  value: _selectedTypeDisplay,
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _selectedTypeDisplay = value;
                                          });
                                        },
                                ),
                                SizedBox(height: 20.h(context)),

                                // Dynamic fields for 'commercial_license'
                                if (_transactionTypes[_selectedTypeDisplay] ==
                                    'commercial_license') ...[
                                  Text(
                                    'تفاصيل الرخصة التجارية',
                                    style: TextStyle(
                                      fontSize: 14.s(context),
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryForest,
                                    ),
                                  ),
                                  SizedBox(height: 12.h(context)),
                                  FormInputField(
                                    label: 'مساحة المحل (بالمتر المربع)',
                                    hint: 'مثال: 45',
                                    controller: _shopAreaController,
                                    keyboardType: TextInputType.number,
                                    enabled: !isLoading,
                                    validator: (val) => Validator.required(val,
                                        message: 'مساحة المحل مطلوبة'),
                                  ),
                                  SizedBox(height: 16.h(context)),
                                  FormInputField(
                                    label: 'نوع النشاط',
                                    hint: 'مثال: سوبرماركت، مكتب خدمات',
                                    controller: _activityTypeController,
                                    enabled: !isLoading,
                                    validator: (val) => Validator.required(val,
                                        message: 'نوع النشاط مطلوب'),
                                  ),
                                  SizedBox(height: 20.h(context)),
                                ] else if (_transactionTypes[
                                        _selectedTypeDisplay] ==
                                    'building_permit') ...[
                                  Container(
                                    padding: EdgeInsets.all(12.r(context)),
                                    decoration: BoxDecoration(
                                      color: AppColors.thirdGoldenWheat
                                          .withValues(alpha: 0.5),
                                      borderRadius:
                                          BorderRadius.circular(12.r(context)),
                                      border: Border.all(
                                          color: AppColors.secondaryGoldenWheat
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      'سيتم تطبيق شروط رخص البناء والبلدية على هذا الطلب. يرجى إرفاق المخططات والوثائق الهندسية أدناه.',
                                      style: TextStyle(
                                        fontSize: 12.s(context),
                                        color: AppColors.secondaryCharcoal,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h(context)),
                                ],

                                // File Attachments Section
                                Text(
                                  'المستندات والوثائق المرفقة',
                                  style: TextStyle(
                                    fontSize: 14.s(context),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryCharcoal,
                                  ),
                                ),
                                SizedBox(height: 10.h(context)),
                                FilePickerContainer(
                                  label: 'انقر هنا لإرفاق المستندات',
                                  onTap: isLoading
                                      ? () {}
                                      : () => cubit.pickFiles(),
                                ),
                                SizedBox(height: 12.h(context)),

                                // Selected Files list
                                if (cubit.attachments.isNotEmpty) ...[
                                  FileAttachmentsList(
                                    files: cubit.attachments,
                                    onRemove: isLoading
                                        ? (_) {}
                                        : (index) => cubit.removeFile(index),
                                  ),
                                  SizedBox(height: 16.h(context)),
                                ],

                                SizedBox(height: 16.h(context)),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52.h(context),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryForest,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            14.r(context)),
                                      ),
                                      elevation: 2,
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () => _submit(context),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            'تقديم الطلب',
                                            style: TextStyle(
                                              fontSize: 15.s(context),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
