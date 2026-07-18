import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:baladeyate/core/widgets/custom_complaint_upload_box.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

Future<void> showComplaintDetailSheet(
  BuildContext context, {
  required Complaint complaint,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24.r(context)),
      ),
    ),
    builder: (sheetContext) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ComplaintsCubit>()),
          BlocProvider(
            create: (ctx) => ComplaintDetailCubit(
              complaint: complaint,
              complaintsCubit: ctx.read<ComplaintsCubit>(),
            )..loadDetail(),
          ),
        ],
        child: const _ComplaintDetailSheet(),
      );
    },
  );
}

class _ComplaintDetailSheet extends StatefulWidget {
  const _ComplaintDetailSheet();

  @override
  State<_ComplaintDetailSheet> createState() => _ComplaintDetailSheetState();
}

class _ComplaintDetailSheetState extends State<_ComplaintDetailSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  bool _controllersInitialized = false;
  int _removedExistingAttachments = 0;
  List<File> _newAttachments = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _detailsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _syncControllers(ComplaintDetailState state) {
    final subject = state.subject;
    final details = state.details;

    if (!_controllersInitialized) {
      _titleController.text = subject;
      _detailsController.text = details;
      _controllersInitialized = true;
      return;
    }

    if (!state.isEditing) {
      if (_titleController.text != subject) {
        _titleController.text = subject;
      }
      if (_detailsController.text != details) {
        _detailsController.text = details;
      }
      _removedExistingAttachments = 0;
      _newAttachments = [];
    }
  }

  int _effectiveAttachmentCount(ComplaintDetailState state) {
    final remaining =
        (state.attachmentCount - _removedExistingAttachments).clamp(0, 999);
    return remaining + _newAttachments.length;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintDetailCubit, ComplaintDetailState>(
      listener: (context, state) => _syncControllers(state),
      builder: (context, state) {
        final complaint = state.complaint;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final canModify =
            complaint.status == 'pending' || complaint.status == 'in_progress';
        final parts = parseComplaintDescription(complaint.description);

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w(context),
            12.h(context),
            20.w(context),
            bottomInset + 24.h(context),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42.w(context),
                      height: 4.h(context),
                      decoration: BoxDecoration(
                        color:
                            AppColors.secondaryCharcoal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'تفاصيل الشكوى #${complaint.id}',
                          style: TextStyle(
                            color: AppColors.primaryForest,
                            fontSize: 18.f(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (state.isBusy)
                        SizedBox(
                          width: 20.s(context),
                          height: 20.s(context),
                          child:
                              const CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h(context)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _ComplaintChip(
                            label: 'الأولوية: ${complaint.priorityText}',
                            color: complaint.priorityColor,
                            background:
                                complaint.priorityColor.withValues(alpha: 0.12),
                            icon: Icons.flag_rounded,
                          ),
                          if (complaint.aiCategory != null &&
                              complaint.aiCategory!.isNotEmpty) ...[
                            SizedBox(height: 8.h(context)),
                            _ComplaintChip(
                              label: complaint.aiCategory!,
                              color: const Color(0xFF235235),
                              background: const Color(0xFFE7F4EC),
                              icon: Icons.category_rounded,
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      _ComplaintChip(
                        label: complaint.statusText,
                        color: complaint.statusForeground,
                        background: complaint.statusBackground,
                        icon: complaint.statusIcon,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h(context)),
                  Text(
                    complaint.formattedDate,
                    style: TextStyle(
                      fontSize: 12.5.f(context),
                      fontWeight: FontWeight.w600,
                      color:
                          AppColors.secondaryCharcoal.withValues(alpha: 0.75),
                    ),
                  ),
                  SizedBox(height: 14.h(context)),
                  if (state.isEditing) ...[
                    Text(
                      'موضوع الشكوى',
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    CustomComplaintInputField(
                      controller: _titleController,
                      hint: 'مثال: صيانة الطرق...',
                      prefixIcon: Icons.title_rounded,
                      onChanged:
                          context.read<ComplaintDetailCubit>().setSubject,
                    ),
                    SizedBox(height: 14.h(context)),
                    Text(
                      'تفاصيل الشكوى',
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    CustomComplaintInputField(
                      controller: _detailsController,
                      hint: 'يرجى كتابة وصف دقيق...',
                      maxLines: 5,
                      onChanged:
                          context.read<ComplaintDetailCubit>().setDetails,
                    ),
                    SizedBox(height: 14.h(context)),
                    Text(
                      'المرفقات',
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    SizedBox(height: 8.h(context)),
                    _buildExistingAttachments(context, state),
                    CustomComplaintUploadBox(
                      onFilesChanged: (files) =>
                          setState(() => _newAttachments = files),
                    ),
                    SizedBox(height: 14.h(context)),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('أولوية عاجلة'),
                      value: state.isUrgent,
                      activeTrackColor: AppColors.green.withValues(alpha: 0.45),
                      activeThumbColor: AppColors.green,
                      onChanged:
                          context.read<ComplaintDetailCubit>().setIsUrgent,
                    ),
                  ] else ...[
                    if (parts.subject.isNotEmpty) ...[
                      Text(
                        parts.subject,
                        style: TextStyle(
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      SizedBox(height: 8.h(context)),
                    ],
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.s(context)),
                      decoration: BoxDecoration(
                        color:
                            AppColors.thirdGoldenWheat.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                      child: Text(
                        parts.details.isEmpty
                            ? (parts.subject.isEmpty
                                ? 'لا يوجد وصف متاح'
                                : parts.subject)
                            : parts.details,
                        style: TextStyle(
                          color:
                              AppColors.secondaryCharcoal.withValues(alpha: 0.9),
                          fontSize: 14.f(context),
                          height: 1.6,
                        ),
                      ),
                    ),
                    if (state.attachmentCount > 0) ...[
                      SizedBox(height: 10.h(context)),
                      Text(
                        '${state.attachmentCount} مرفق',
                        style: TextStyle(
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryForest.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                  if (canModify) ...[
                    SizedBox(height: 16.h(context)),
                    Row(
                      children: [
                        if (state.isEditing) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.isBusy
                                  ? null
                                  : () => context
                                      .read<ComplaintDetailCubit>()
                                      .cancelEditing(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryForest,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r(context)),
                                ),
                              ),
                              child: const Text('إلغاء'),
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.isBusy
                                  ? null
                                  : () => _saveChanges(context, state),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r(context)),
                                ),
                              ),
                              child: const Text('حفظ'),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: state.isBusy
                                  ? null
                                  : () => context
                                      .read<ComplaintDetailCubit>()
                                      .startEditing(),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('تعديل'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primaryForest,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r(context)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: state.isBusy
                                  ? null
                                  : () => _confirmDelete(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.alertRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12.r(context)),
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('حذف'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingAttachments(
    BuildContext context,
    ComplaintDetailState state,
  ) {
    final remaining =
        (state.attachmentCount - _removedExistingAttachments).clamp(0, 999);
    if (remaining == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h(context)),
      child: Wrap(
        spacing: 10.s(context),
        runSpacing: 10.s(context),
        alignment: WrapAlignment.end,
        children: List.generate(remaining, (index) {
          return Stack(
            children: [
              Container(
                width: 72.s(context),
                height: 72.s(context),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12.r(context)),
                  border: Border.all(
                    color: AppColors.primaryForest.withValues(alpha: 0.12),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.primaryForest.withValues(alpha: 0.6),
                  size: 28.ic(context),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _removedExistingAttachments++),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14.ic(context),
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _saveChanges(
    BuildContext context,
    ComplaintDetailState state,
  ) async {
    context.read<ComplaintDetailCubit>()
      ..setSubject(_titleController.text)
      ..setDetails(_detailsController.text);

    final success = await context.read<ComplaintDetailCubit>().saveChanges(
          attachmentCount: _effectiveAttachmentCount(state),
        );
    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الشكوى')),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
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
                    color: AppColors.alertRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.alertRed,
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
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.85),
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
                    color: AppColors.secondaryCharcoal,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
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

    if (confirmed != true || !context.mounted) return;

    final success =
        await context.read<ComplaintDetailCubit>().deleteComplaint();
    if (!context.mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الشكوى')),
      );
    }
  }
}

class _ComplaintChip extends StatelessWidget {
  const _ComplaintChip({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w(context),
        vertical: 6.h(context),
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20.r(context)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.ic(context), color: color),
          SizedBox(width: 5.w(context)),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.f(context),
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
