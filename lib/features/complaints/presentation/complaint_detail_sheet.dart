import 'package:baladeyate/config/theme/app_colors.dart';
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
      return BlocProvider.value(
        value: context.read<ComplaintsCubit>(),
        child: _ComplaintDetailSheet(complaint: complaint),
      );
    },
  );
}

class _ComplaintDetailSheet extends StatefulWidget {
  const _ComplaintDetailSheet({required this.complaint});

  final Complaint complaint;

  @override
  State<_ComplaintDetailSheet> createState() => _ComplaintDetailSheetState();
}

class _ComplaintDetailSheetState extends State<_ComplaintDetailSheet> {
  late final TextEditingController _descriptionController;
  late bool _isUrgent;
  bool _isEditing = false;
  bool _isBusy = false;
  Complaint? _complaint;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _descriptionController =
        TextEditingController(text: widget.complaint.description);
    _isUrgent = widget.complaint.priority == 'urgent';
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isBusy = true);
    final detail =
        await context.read<ComplaintsCubit>().loadComplaintDetail(widget.complaint.id);
    if (!mounted) return;
    if (detail != null) {
      setState(() {
        _complaint = detail;
        _descriptionController.text = detail.description;
        _isUrgent = detail.priority == 'urgent';
      });
    }
    setState(() => _isBusy = false);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canModify =>
      _complaint?.status == 'pending' || _complaint?.status == 'in_progress';

  @override
  Widget build(BuildContext context) {
    final complaint = _complaint ?? widget.complaint;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

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
                if (_isBusy)
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
            if (complaint.aiCategory != null && complaint.aiCategory!.isNotEmpty)
              _InfoRow(label: 'التصنيف', value: complaint.aiCategory!),
            SizedBox(height: 12.h(context)),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                maxLines: 5,
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
            if (_canModify) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('أولوية عاجلة'),
                value: _isUrgent,
                onChanged: _isEditing
                    ? (value) => setState(() => _isUrgent = value)
                    : null,
              ),
              Row(
                children: [
                  if (_isEditing) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isBusy
                            ? null
                            : () => setState(() => _isEditing = false),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isBusy ? null : _saveChanges,
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
                        onPressed: _isBusy
                            ? null
                            : () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('تعديل'),
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isBusy ? null : _confirmDelete,
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
  }

  Future<void> _saveChanges() async {
    setState(() => _isBusy = true);
    final success = await context.read<ComplaintsCubit>().updateComplaint(
          id: widget.complaint.id,
          description: _descriptionController.text.trim(),
          isUrgent: _isUrgent,
        );
    if (!mounted) return;
    setState(() {
      _isBusy = false;
      if (success) _isEditing = false;
    });
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الشكوى')),
      );
    }
  }

  Future<void> _confirmDelete() async {
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

    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    final success =
        await context.read<ComplaintsCubit>().deleteComplaint(widget.complaint.id);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الشكوى')),
      );
    } else {
      setState(() => _isBusy = false);
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
