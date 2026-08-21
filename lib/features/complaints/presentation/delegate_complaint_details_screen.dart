import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaint_detail_cubit/delegate_complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaint_detail_cubit/delegate_complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_attachment_gallery.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_header_content.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_info_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_section_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/delegate_complaint_map.dart';
import 'package:baladeyate/features/complaints/presentation/components/delegate_field_report_sheet.dart';
import 'package:baladeyate/features/complaints/repo/complaints_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:url_launcher/url_launcher.dart';

class DelegateComplaintDetailsScreen extends StatelessWidget {
  const DelegateComplaintDetailsScreen({
    super.key,
    required this.complaintId,
    this.initialComplaint,
  });

  final int complaintId;
  final Complaint? initialComplaint;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DelegateComplaintDetailCubit(
        repository: sl<ComplaintsRepository>(),
        complaintId: complaintId,
        initialComplaint: initialComplaint,
      )..load(),
      child: const _DelegateComplaintDetailsView(),
    );
  }
}

class _DelegateComplaintDetailsView extends StatelessWidget {
  const _DelegateComplaintDetailsView();

  @override
  Widget build(BuildContext context) {
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
        body: BlocConsumer<DelegateComplaintDetailCubit,
            DelegateComplaintDetailState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.complaint != null &&
                !state.isLoading) {
              AppSnackBar.showError(context, state.errorMessage!);
            }
          },
          builder: (context, state) {
            final complaint = state.complaint;
            if (complaint == null && state.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.pageProgress(context),
                ),
              );
            }
            if (complaint == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.s(context)),
                  child: Text(
                    state.errorMessage ?? 'تعذر عرض تفاصيل الشكوى',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  color: AppColors.primaryForest,
                  onRefresh: () =>
                      context.read<DelegateComplaintDetailCubit>().load(),
                  child: _ComplaintBody(complaint: complaint),
                ),
                if (state.isSubmitting)
                  const ModalBarrier(
                    dismissible: false,
                    color: Color(0x33000000),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ComplaintBody extends StatelessWidget {
  const _ComplaintBody({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final parts = parseComplaintDescription(complaint.description);
    final address = addressValueFromLine(parts.addressLine);
    final coordinates = complaint.mapCoordinates;
    final message = complaint.citizenMessage;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16.s(context),
        8.h(context),
        16.s(context),
        24.h(context) + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Text(
          'تفاصيل الشكوى الميدانية',
          style: TextStyle(
            fontSize: 18.f(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ComplaintDetailsInfoCard(
          children: [
            ComplaintDetailsHeaderContent(complaint: complaint),
            if (complaint.departmentLabel != null &&
                complaint.departmentLabel!.isNotEmpty) ...[
              SizedBox(height: 12.h(context)),
              Text(
                'القسم: ${complaint.departmentLabel}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13.f(context),
                ),
              ),
            ],
          ],
        ),
        if (complaint.citizenName != null || complaint.citizenPhone != null)
          ComplaintDetailsInfoCard(
            children: [
              ComplaintDetailsSectionCard(
                icon: Icons.person_outline,
                title: 'بيانات المواطن',
                body: [
                  if (complaint.citizenName != null) complaint.citizenName!,
                  if (complaint.citizenPhone != null) complaint.citizenPhone!,
                ].join('\n'),
              ),
              if (complaint.citizenPhone != null) ...[
                SizedBox(height: 8.h(context)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri(scheme: 'tel', path: complaint.citizenPhone),
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('اتصال بالمواطن'),
                  ),
                ),
              ],
            ],
          ),
        ComplaintDetailsInfoCard(
          children: [
            ComplaintDetailsSectionCard(
              icon: Icons.description_outlined,
              title: 'نص الشكوى',
              body: message.isNotEmpty ? message : complaint.description,
            ),
          ],
        ),
        ComplaintDetailsInfoCard(
          children: [
            ComplaintDetailsSectionCard(
              icon: Icons.location_on_outlined,
              title: 'موقع الشكوى',
              body: coordinates == null
                  ? (address ?? 'لم يُحدد موقع على الخريطة')
                  : (address ?? 'تم تحديد الموقع على الخريطة'),
            ),
            if (coordinates != null) ...[
              SizedBox(height: 12.h(context)),
              DelegateComplaintMap(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                address: address,
              ),
            ],
          ],
        ),
        ComplaintDetailsInfoCard(
          children: [
            ComplaintDetailsSectionCard(
              icon: Icons.photo_library_outlined,
              title: 'صور المواطن',
              body: complaint.imageAttachments.isEmpty
                  ? 'لا توجد صور مرفقة مع هذه الشكوى'
                  : '${complaint.imageAttachments.length} صورة مرفقة مع الشكوى',
            ),
            SizedBox(height: 12.h(context)),
            ComplaintAttachmentGallery(urls: complaint.imageAttachments),
          ],
        ),
        if (complaint.fieldNotes != null &&
            complaint.fieldNotes!.trim().isNotEmpty)
          ComplaintDetailsInfoCard(
            children: [
              ComplaintDetailsSectionCard(
                icon: Icons.fact_check_outlined,
                title: 'آخر تقرير ميداني',
                body: [
                  if (complaint.fieldOutcomeLabel != null)
                    complaint.fieldOutcomeLabel!,
                  complaint.fieldNotes!,
                ].join('\n'),
              ),
            ],
          ),
        SizedBox(height: 8.h(context)),
        SizedBox(
          width: double.infinity,
          height: 52.h(context),
          child: ElevatedButton.icon(
            onPressed: () => _submitReport(context, complaint),
            icon: const Icon(Icons.report_outlined, color: Colors.white),
            label: const Text(
              'تقديم تقرير ميداني',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submitReport(BuildContext context, Complaint complaint) async {
    final cubit = context.read<DelegateComplaintDetailCubit>();
    final result = await showModalBottomSheet<DelegateFieldReportDraft>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DelegateFieldReportSheet(complaint: complaint),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final ok = await cubit.submitFieldReport(
      notes: result.notes,
      outcome: result.outcome,
      attachments: result.photos,
    );
    if (!context.mounted) {
      return;
    }
    if (ok) {
      AppSnackBar.showSuccess(context, 'تم إرسال التقرير الميداني');
      context.pop(true);
    }
  }
}
