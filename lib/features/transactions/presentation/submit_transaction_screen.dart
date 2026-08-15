import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';

import '../cubits/submit_transaction_cubit/submit_transaction_cubit.dart';
import '../cubits/submit_transaction_cubit/submit_transaction_state.dart';
import 'components/file_attachments_list.dart';
import 'components/file_picker_container.dart';
import 'components/required_documents_guide.dart';

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

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 14.s(context),
      ),
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 14.s(context),
      ),
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.grey.shade100,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: primaryColor) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r(context)),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w(context),
        vertical: 16.h(context),
      ),
    );
  }

  Widget _buildDynamicFields(
    BuildContext context,
    SubmitTransactionState state,
    bool isLoading,
  ) {
    final cubit = context.read<SubmitTransactionCubit>();

    if (state.selectedType == 'commercial_license') {
      return Column(
        key: const ValueKey('commercial_license_fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h(context)),
          TextFormField(
            initialValue: state.formData['commercial_name'] as String?,
            enabled: !isLoading,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.s(context),
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            decoration: _buildInputDecoration(
              context,
              labelText: 'الاسم التجاري',
              hintText: 'مثال: متجر الأمل للمواد الغذائية',
              prefixIcon: Icons.storefront_outlined,
            ),
            onChanged: (val) => cubit.updateFormField('commercial_name', val),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال الاسم التجاري' : null,
          ),
          SizedBox(height: 16.h(context)),
          TextFormField(
            initialValue: state.formData['shop_area'] as String?,
            enabled: !isLoading,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.s(context),
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: _buildInputDecoration(
              context,
              labelText: 'مساحة المحل (بالمتر المربع)',
              hintText: 'مثال: 45',
              prefixIcon: Icons.square_foot_outlined,
            ),
            onChanged: (val) => cubit.updateFormField('shop_area', val),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال مساحة المحل' : null,
          ),
        ],
      );
    } else if (state.selectedType == 'building_permit') {
      return Column(
        key: const ValueKey('building_permit_fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h(context)),
          TextFormField(
            initialValue: state.formData['building_type'] as String?,
            enabled: !isLoading,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.s(context),
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            decoration: _buildInputDecoration(
              context,
              labelText: 'نوع البناء',
              hintText: 'مثال: سكني، تجاري، فلة',
              prefixIcon: Icons.domain_outlined,
            ),
            onChanged: (val) => cubit.updateFormField('building_type', val),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال نوع البناء' : null,
          ),
          SizedBox(height: 16.h(context)),
          TextFormField(
            initialValue: state.formData['building_area'] as String?,
            enabled: !isLoading,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.s(context),
              fontWeight: FontWeight.w500,
            ),
            keyboardType: TextInputType.number,
            textDirection: TextDirection.rtl,
            decoration: _buildInputDecoration(
              context,
              labelText: 'مساحة البناء الإجمالية (م²)',
              hintText: 'مثال: 250',
              prefixIcon: Icons.straighten_outlined,
            ),
            onChanged: (val) => cubit.updateFormField('building_area', val),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'يرجى إدخال مساحة البناء' : null,
          ),
        ],
      );
    } else if (state.selectedType == 'general_service') {
      return Column(
        key: const ValueKey('general_service_fields'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h(context)),
          TextFormField(
            initialValue: state.formData['service_description'] as String?,
            enabled: !isLoading,
            maxLines: 4,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 15.s(context),
              fontWeight: FontWeight.w500,
            ),
            textDirection: TextDirection.rtl,
            decoration: _buildInputDecoration(
              context,
              labelText: 'وصف الخدمة المطلوبة',
              hintText: 'اشرح الخدمة البلدية التي تحتاجها',
              prefixIcon: Icons.description_outlined,
            ),
            onChanged: (val) =>
                cubit.updateFormField('service_description', val),
            validator: (val) => (val == null || val.trim().isEmpty)
                ? 'يرجى إدخال وصف الخدمة'
                : null,
          ),
        ],
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty_fields'));
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocConsumer<SubmitTransactionCubit, SubmitTransactionState>(
      listener: (context, state) {
        if (state is SubmitTransactionFailure) {
          AppSnackBar.showError(context, state.error);
        } else if (state is SubmitTransactionSuccess) {
          AppSnackBar.showSuccess(
            context,
            'تم تقديم الطلب بنجاح. رقم المعاملة: ${state.transactionNumber}',
          );
          Navigator.pop(context, true);
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
                                // Dropdown for transaction type with prefix icon & dark typography
                                DropdownButtonFormField<String>(
                                  initialValue: state.selectedType,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r(context)),
                                  elevation: 4,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15.s(context),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: _buildInputDecoration(
                                    context,
                                    labelText: 'نوع المعاملة',
                                    hintText: 'اختر نوع المعاملة',
                                    prefixIcon: Icons.assignment_outlined,
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: primaryColor,
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'commercial_license',
                                      child: Text(
                                        'رخصة تجارية',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15.s(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'building_permit',
                                      child: Text(
                                        'تصريح بناء',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15.s(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 'general_service',
                                      child: Text(
                                        'خدمة عامة',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15.s(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: isLoading
                                      ? null
                                      : (value) {
                                          if (value != null) {
                                            cubit.changeTransactionType(value);
                                          }
                                        },
                                  validator: (val) => val == null || val.isEmpty
                                      ? 'يرجى اختيار نوع المعاملة'
                                      : null,
                                ),

                                // Dynamic Form Fields based on selected type using AnimatedSize
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _buildDynamicFields(
                                    context,
                                    state,
                                    isLoading,
                                  ),
                                ),

                                if (state.selectedType != null) ...[
                                  SizedBox(height: 16.h(context)),
                                  RequiredDocumentsGuide(
                                    type: state.selectedType,
                                  ),
                                ],

                                SizedBox(height: 24.h(context)),

                                // File Picker Section
                                Text(
                                  'المستندات والوثائق المرفقة',
                                  style: TextStyle(
                                    fontSize: 14.s(context),
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryCharcoal,
                                  ),
                                ),
                                SizedBox(height: 6.h(context)),
                                Text(
                                  'ارفع الملفات حسب القائمة أعلاه (كل وثيقة إلزامية في ملف مستقل).',
                                  style: TextStyle(
                                    fontSize: 12.s(context),
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(height: 10.h(context)),

                                FilePickerContainer(
                                  label: 'انقر هنا لإرفاق المستندات والملفات',
                                  onTap: isLoading
                                      ? () {}
                                      : () => cubit.pickFiles(),
                                ),
                                SizedBox(height: 12.h(context)),

                                // Selected Files List
                                FileAttachmentsList(
                                  files: state.attachedFiles,
                                  onRemove: isLoading
                                      ? (_) {}
                                      : (index) => cubit.removeFile(index),
                                ),

                                SizedBox(height: 24.h(context)),

                                // Full Width Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54.h(context),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      disabledBackgroundColor:
                                          primaryColor.withValues(alpha: 0.7),
                                      disabledForegroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.r(context),
                                        ),
                                      ),
                                    ),
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            if (_formKey.currentState?.validate() ?? false) {
                                              cubit.submitTransaction(
                                                buildingId: widget.buildingId,
                                              );
                                            }
                                          },
                                    child: isLoading
                                        ? SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: AppColors
                                                  .contrastingProgress(
                                                primaryColor,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'تقديم الطلب',
                                            style: TextStyle(
                                              fontSize: 16.s(context),
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
