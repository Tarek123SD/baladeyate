import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:baladeyate/core/widgets/custom_complaint_map_box.dart';
import 'package:baladeyate/core/widgets/custom_complaint_priority_button.dart';
import 'package:baladeyate/core/widgets/custom_complaint_upload_box.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_form_error_section.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_form_header.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_form_section_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_submit_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  List<File> _attachments = [];
  LatLng? _selectedLocation;
  String _addressText = '';
  bool _isUrgent = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintsCubit, ComplaintsState>(
      listenWhen: (previous, current) =>
          current is ComplaintCreated || current is ComplaintsFailure,
      listener: (context, state) {
        if (state is ComplaintCreated) {
          AppSnackBar.showSuccess(
            context,
            'تم إرسال شكواك وسيتم توجيهها إلى القسم المختص.',
          );
          context.go('/track');
        }
      },
      buildWhen: (previous, current) =>
          previous is ComplaintsLoading != current is ComplaintsLoading ||
          previous is ComplaintsFailure != current is ComplaintsFailure ||
          (previous is ComplaintsFailure &&
              current is ComplaintsFailure &&
              previous.message != current.message),
      builder: (context, state) {
        final isSubmitting = state is ComplaintsLoading;
        final errorMessage = state is ComplaintsFailure ? state.message : null;

        return Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.s(context)),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 700.w(context),
                          ),
                          child: _buildFormCard(
                            context,
                            isSubmitting,
                            errorMessage,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Row(
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/track');
              }
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryForest,
              size: 20.ic(context),
            ),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Text(
              'تقديم شكوى',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 20.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 48.s(context)),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context,
    bool isSubmitting,
    String? errorMessage,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 8.s(context)),
          const Center(child: ComplaintFormHeader()),
          SizedBox(height: 18.s(context)),
          ComplaintFormSectionCard(
            title: 'درجة الأولوية',
            child: Row(
              children: [
                Expanded(
                  child: CustomComplaintPriorityButton(
                    text: 'طارئ / مستعجل',
                    isActive: _isUrgent,
                    onTap: isSubmitting
                        ? null
                        : () => setState(() => _isUrgent = true),
                  ),
                ),
                SizedBox(width: 10.s(context)),
                Expanded(
                  child: CustomComplaintPriorityButton(
                    text: 'اعتيادي',
                    isActive: !_isUrgent,
                    onTap: isSubmitting
                        ? null
                        : () => setState(() => _isUrgent = false),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.s(context)),
          ComplaintFormSectionCard(
            title: 'موضوع الشكوى',
            child: CustomComplaintInputField(
              controller: _subjectController,
              hint: 'مثال: صيانة الطرق...',
              prefixIcon: Icons.subject_rounded,
            ),
          ),
          SizedBox(height: 14.s(context)),
          ComplaintFormSectionCard(
            title: 'تفاصيل الشكوى',
            child: CustomComplaintInputField(
              controller: _detailsController,
              hint: 'يرجى كتابة وصف دقيق...',
              maxLines: 5,
            ),
          ),
          SizedBox(height: 14.s(context)),
          ComplaintFormSectionCard(
            title: 'المرفقات و الصور',
            child: CustomComplaintUploadBox(
              onFilesChanged: (files) => _attachments = List<File>.from(files),
            ),
          ),
          SizedBox(height: 14.s(context)),
          ComplaintFormSectionCard(
            title: 'الموقع الجغرافي',
            child: CustomComplaintMapBox(
              key: const ValueKey('complaint-map-box'),
              onLocationSelected: (location) {
                _selectedLocation = location;
              },
              onAddressChanged: (address) {
                _addressText = address.trim();
              },
            ),
          ),
          SizedBox(height: 18.s(context)),
          if (errorMessage != null) ...[
            ComplaintFormErrorSection(
              message: errorMessage,
              onRetry: () => _submitComplaint(context),
            ),
            SizedBox(height: 14.s(context)),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : () => _submitComplaint(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.green.withValues(alpha: 0.7),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 13.h(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                ),
              ),
              icon: isSubmitting
                  ? SizedBox(
                      width: 18.s(context),
                      height: 18.s(context),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.contrastingProgress(AppColors.green),
                      ),
                    )
                  : Icon(
                      Icons.send_rounded,
                      size: 18.s(context),
                    ),
              label: Text(
                'إرسال الشكوى',
                style: TextStyle(
                  fontSize: 15.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.s(context)),
        ],
      ),
    );
  }

  Future<void> _submitComplaint(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final details = _detailsController.text.trim();

    if (details.isEmpty) {
      AppSnackBar.showError(context, 'يرجى كتابة تفاصيل الشكوى');
      return;
    }

    final confirmed = await showComplaintSubmitConfirmationDialog(context);
    if (confirmed != true || !context.mounted) return;

    _sendComplaint(context);
  }

  void _sendComplaint(BuildContext context) {
    final subject = _subjectController.text.trim();
    final details = _detailsController.text.trim();

    final buffer =
        StringBuffer(subject.isEmpty ? details : '$subject\n$details');

    if (_addressText.isNotEmpty) {
      buffer.write('\nعنوان الموقع: $_addressText');
    }

    final selectedLocation = _selectedLocation;
    if (selectedLocation != null) {
      buffer
        ..write('\nالموقع: ')
        ..write(selectedLocation.latitude.toStringAsFixed(5))
        ..write(', ')
        ..write(selectedLocation.longitude.toStringAsFixed(5));
    }

    context.read<ComplaintsCubit>().createComplaint(
          description: buffer.toString(),
          isUrgent: _isUrgent,
          attachments: List<File>.from(_attachments),
        );
  }
}
