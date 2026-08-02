import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_delete_confirmation_dialog.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_delete_bar.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_header_content.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_info_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  const ComplaintDetailsScreen({
    super.key,
    required this.complaint,
  });

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final complaintDetailCubit = _tryRead<ComplaintDetailCubit>(context);

    if (complaintDetailCubit != null) {
      return BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
        builder: (context, state) {
          return _buildScreen(context, state.complaint);
        },
      );
    }

    return _buildScreen(context, complaint);
  }

  static T? _tryRead<T extends StateStreamableSource<Object?>>(
      BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildScreen(BuildContext context, Complaint targetComplaint) {
    final parts = parseComplaintDescription(targetComplaint.description);
    final locationDisplay = targetComplaint.cardLocationDisplay;

    // Strict Business Rule: Only pending or in_progress complaints can be deleted
    final bool canDelete = targetComplaint.status == 'pending' ||
        targetComplaint.status == 'in_progress';

    final descriptionBody = parts.details.isNotEmpty
        ? parts.details
        : (parts.subject.isNotEmpty
            ? parts.subject
            : targetComplaint.description);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'تفاصيل الشكوى',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18.f(context),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.s(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ComplaintDetailsInfoCard(
                children: [
                  ComplaintDetailsHeaderContent(complaint: targetComplaint),
                ],
              ),
              ComplaintDetailsInfoCard(
                children: [
                  ComplaintDetailsSectionCard(
                    icon: Icons.description_outlined,
                    title: 'نص الشكوى',
                    body: descriptionBody,
                  ),
                ],
              ),
              if (locationDisplay != null && locationDisplay.isNotEmpty)
                ComplaintDetailsInfoCard(
                  children: [
                    ComplaintDetailsSectionCard(
                      icon: Icons.location_on_outlined,
                      title: 'الموقع',
                      body: locationDisplay,
                      bodyHeight: 1.4,
                    ),
                  ],
                ),
            ],
          ),
        ),
        bottomNavigationBar: canDelete
            ? ComplaintDetailsDeleteBar(
                onDelete: () => _confirmDelete(context, targetComplaint),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Complaint targetComplaint,
  ) async {
    final detailCubit = _tryRead<ComplaintDetailCubit>(context);
    final complaintsCubit = _tryRead<ComplaintsCubit>(context);
    final navigator = Navigator.of(context);

    final confirmed = await showComplaintDeleteConfirmationDialog(context);

    if (confirmed != true) return;

    bool success = false;
    if (detailCubit != null) {
      success = await detailCubit.deleteComplaint();
    } else if (complaintsCubit != null) {
      success = await complaintsCubit.deleteComplaint(targetComplaint.id);
    }

    if (success) {
      navigator.pop();
      if (context.mounted) {
        AppSnackBar.showSuccess(context, 'تم حذف الشكوى بنجاح');
      }
    }
  }
}
