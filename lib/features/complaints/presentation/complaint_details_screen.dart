import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final parts = parseComplaintDescription(targetComplaint.description);
    final locationDisplay = targetComplaint.cardLocationDisplay;

    // Strict Business Rule: Only pending or in_progress complaints can be deleted
    final bool canDelete = targetComplaint.status == 'pending' ||
        targetComplaint.status == 'in_progress';

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
              // CARD 1: Header Info
              _buildInfoCard(
                context: context,
                children: [
                  // Row 1: Title & Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          targetComplaint.displayTitle,
                          style: TextStyle(
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w(context)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w(context),
                          vertical: 6.h(context),
                        ),
                        decoration: BoxDecoration(
                          color: targetComplaint.statusBackground,
                          borderRadius: BorderRadius.circular(8.r(context)),
                        ),
                        child: Text(
                          targetComplaint.statusText,
                          style: TextStyle(
                            color: targetComplaint.statusForeground,
                            fontSize: 12.f(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h(context)),

                  // Divider
                  Divider(color: Colors.grey.shade200, height: 1),
                  SizedBox(height: 12.h(context)),

                  // Row 2: Ticket Number & Date/Time
                  Row(
                    children: [
                      Text(
                        '#${targetComplaint.id}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.f(context),
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14.f(context),
                        ),
                      ),
                      Text(
                        targetComplaint.formattedDate,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.f(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h(context)),

                  // Row 3: Urgency & Category Tags
                  Wrap(
                    spacing: 8.w(context),
                    runSpacing: 6.h(context),
                    children: [
                      if (targetComplaint.priority == 'urgent')
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w(context),
                            vertical: 4.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6.r(context)),
                          ),
                          child: Text(
                            'طارئ',
                            style: TextStyle(
                              color: const Color(0xFFC62828),
                              fontSize: 11.f(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else if (targetComplaint.priorityText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w(context),
                            vertical: 4.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: targetComplaint.priorityColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r(context)),
                          ),
                          child: Text(
                            targetComplaint.priorityText,
                            style: TextStyle(
                              color: targetComplaint.priorityColor,
                              fontSize: 11.f(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (targetComplaint.aiCategory != null &&
                          targetComplaint.aiCategory!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w(context),
                            vertical: 4.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(6.r(context)),
                          ),
                          child: Text(
                            targetComplaint.aiCategory!,
                            style: TextStyle(
                              color: const Color(0xFF2E7D32),
                              fontSize: 11.f(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // CARD 2: Description
              _buildInfoCard(
                context: context,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18.ic(context),
                        color: Colors.grey.shade800,
                      ),
                      SizedBox(width: 8.w(context)),
                      Text(
                        'نص الشكوى',
                        style: TextStyle(
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    parts.details.isNotEmpty
                        ? parts.details
                        : (parts.subject.isNotEmpty
                            ? parts.subject
                            : targetComplaint.description),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14.f(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),

              // CARD 3: Location / Address (if applicable)
              if (locationDisplay != null && locationDisplay.isNotEmpty)
                _buildInfoCard(
                  context: context,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18.ic(context),
                          color: Colors.grey.shade800,
                        ),
                        SizedBox(width: 8.w(context)),
                        Text(
                          'الموقع',
                          style: TextStyle(
                            fontSize: 15.f(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h(context)),
                    Text(
                      locationDisplay,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14.f(context),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // CONDITIONAL DELETE ACTION AREA (Bottom Navigation Bar)
        bottomNavigationBar: canDelete
            ? SafeArea(
                child: Container(
                  padding: EdgeInsets.all(16.s(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50.h(context),
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmDelete(context, targetComplaint),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r(context)),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(
                        'حذف الشكوى',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.f(context),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  /// Helper method to build clean white container cards
  Widget _buildInfoCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      margin: EdgeInsets.only(bottom: 16.h(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Delete Confirmation Dialog & Execution
  Future<void> _confirmDelete(
    BuildContext context,
    Complaint targetComplaint,
  ) async {
    final detailCubit = _tryRead<ComplaintDetailCubit>(context);
    final complaintsCubit = _tryRead<ComplaintsCubit>(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r(dialogContext)),
            ),
            contentPadding: EdgeInsets.fromLTRB(
              20.w(dialogContext),
              20.h(dialogContext),
              20.w(dialogContext),
              8.h(dialogContext),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(14.s(dialogContext)),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 32.ic(dialogContext),
                  ),
                ),
                SizedBox(height: 16.h(dialogContext)),
                Text(
                  'حذف الشكوى',
                  style: TextStyle(
                    fontSize: 18.f(dialogContext),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 8.h(dialogContext)),
                Text(
                  'هل أنت متأكد من حذف هذه الشكوى؟ لا يمكن التراجع عن هذا الإجراء.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.f(dialogContext),
                    height: 1.6,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.fromLTRB(
              16.w(dialogContext),
              0,
              16.w(dialogContext),
              16.h(dialogContext),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 14.f(dialogContext),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r(dialogContext)),
                  ),
                ),
                child: Text(
                  'حذف',
                  style: TextStyle(
                    fontSize: 14.f(dialogContext),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true) return;

    bool success = false;
    if (detailCubit != null) {
      success = await detailCubit.deleteComplaint();
    } else if (complaintsCubit != null) {
      success = await complaintsCubit.deleteComplaint(targetComplaint.id);
    }

    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('تم حذف الشكوى بنجاح')),
      );
    }
  }
}
