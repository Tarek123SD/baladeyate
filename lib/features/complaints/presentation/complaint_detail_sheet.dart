import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
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
  late final TextEditingController _descriptionController;
  bool _controllerInitialized = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComplaintDetailCubit, ComplaintDetailState>(
      listener: (context, state) {
        if (!_controllerInitialized) {
          _descriptionController =
              TextEditingController(text: state.description);
          _controllerInitialized = true;
        } else if (!_descriptionController.text.startsWith(state.description) &&
            state.description != _descriptionController.text) {
          _descriptionController.text = state.description;
        }
      },
      builder: (context, state) {
        if (!_controllerInitialized) {
          _descriptionController =
              TextEditingController(text: state.description);
          _controllerInitialized = true;
        }

        final complaint = state.complaint;
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
        final canModify =
            complaint.status == 'pending' || complaint.status == 'in_progress';

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20.w(context),
            12.h(context),
            20.w(context),
            bottomInset + 24.h(context),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
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
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                SizedBox(height: 12.h(context)),
                _InfoRow(
                  label: 'الحالة',
                  value: complaint.statusLabel ?? complaint.status,
                ),
                _InfoRow(label: 'الأولوية', value: complaint.priority),
                if (complaint.aiCategory != null &&
                    complaint.aiCategory!.isNotEmpty)
                  _InfoRow(label: 'التصنيف', value: complaint.aiCategory!),
                SizedBox(height: 12.h(context)),
                if (state.isEditing)
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    onChanged: context.read<ComplaintDetailCubit>().setDescription,
                    decoration: InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                    ),
                  )
                else
                  Text(
                    complaint.description,
                    style: TextStyle(
                      color: AppColors.secondaryCharcoal,
                      fontSize: 14.f(context),
                      height: 1.6,
                    ),
                  ),
                SizedBox(height: 16.h(context)),
                if (canModify) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('أولوية عاجلة'),
                    value: state.isUrgent,
                    onChanged: state.isEditing
                        ? context.read<ComplaintDetailCubit>().setIsUrgent
                        : null,
                  ),
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
                            child: const Text('إلغاء'),
                          ),
                        ),
                        SizedBox(width: 8.w(context)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                state.isBusy ? null : () => _saveChanges(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
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
                          ),
                        ),
                        SizedBox(width: 8.w(context)),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                state.isBusy ? null : () => _confirmDelete(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC62828),
                              foregroundColor: Colors.white,
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
        );
      },
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    context.read<ComplaintDetailCubit>().setDescription(
          _descriptionController.text,
        );
    final success =
        await context.read<ComplaintDetailCubit>().saveChanges();
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الشكوى'),
        content: const Text('هل أنت متأكد من حذف هذه الشكوى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h(context)),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontWeight: FontWeight.w600,
                fontSize: 13.f(context),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
              fontSize: 13.f(context),
            ),
          ),
        ],
      ),
    );
  }
}
