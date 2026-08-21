import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaints_cubit/delegate_complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/delegate_complaints_cubit/delegate_complaints_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

const _fieldOutcomes = <String, String>{
  'completed': 'تم الكشف الميداني',
  'needs_follow_up': 'تحتاج جولة ثانية',
  'unreachable': 'تعذر الوصول',
};

class DelegateComplaintsScreen extends StatelessWidget {
  const DelegateComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DelegateComplaintsCubit>()..fetch(),
      child: const _DelegateComplaintsView(),
    );
  }
}

class _DelegateComplaintsView extends StatelessWidget {
  const _DelegateComplaintsView();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
            child: BlocConsumer<DelegateComplaintsCubit, DelegateComplaintsState>(
              listener: (context, state) {
                if (state is DelegateComplaintsError) {
                  AppSnackBar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () =>
                      context.read<DelegateComplaintsCubit>().fetch(),
                  child: ResponsiveBody(
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 8.h(context),
                              bottom: 16.h(context),
                            ),
                            child: Text(
                              'شكاوى الكشف الميداني',
                              style: TextStyle(
                                fontSize: 18.f(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (state is DelegateComplaintsLoading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.pageProgress(context),
                              ),
                            ),
                          )
                        else if (state is DelegateComplaintsLoaded &&
                            state.complaints.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد شكاوى بانتظار الكشف حالياً',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.f(context),
                                ),
                              ),
                            ),
                          )
                        else if (state is DelegateComplaintsLoaded)
                          SliverList.builder(
                            itemCount: state.complaints.length,
                            itemBuilder: (context, index) {
                              final complaint = state.complaints[index];
                              return _DelegateComplaintTile(
                                complaint: complaint,
                                onInspect: () =>
                                    _showInspectSheet(context, complaint),
                              );
                            },
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox.shrink()),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 24.h(context)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showInspectSheet(
    BuildContext context,
    Complaint complaint,
  ) async {
    final cubit = context.read<DelegateComplaintsCubit>();
    final result = await showModalBottomSheet<_FieldReportDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _FieldReportSheet(complaint: complaint),
    );

    if (result == null || !context.mounted) {
      return;
    }

    final ok = await cubit.submitFieldReport(
      complaintId: complaint.id,
      notes: result.notes,
      outcome: result.outcome,
      attachments: result.photos,
    );
    if (!context.mounted) {
      return;
    }
    if (ok) {
      AppSnackBar.showSuccess(context, 'تم إرسال التقرير الميداني');
    }
  }
}

class _FieldReportDraft {
  const _FieldReportDraft({
    required this.notes,
    required this.outcome,
    required this.photos,
  });

  final String notes;
  final String outcome;
  final List<File> photos;
}

class _FieldReportSheet extends StatefulWidget {
  const _FieldReportSheet({required this.complaint});

  final Complaint complaint;

  @override
  State<_FieldReportSheet> createState() => _FieldReportSheetState();
}

class _FieldReportSheetState extends State<_FieldReportSheet> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  String _outcome = 'completed';
  final List<XFile> _photos = [];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_photos.length >= 5) {
      return;
    }
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) {
      return;
    }
    setState(() => _photos.add(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24.r(context)),
            ),
          ),
          padding: EdgeInsets.all(20.s(context)),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تقرير ميداني — شكوى #${widget.complaint.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.f(context),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                Text(
                  'نتيجة الكشف',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.f(context),
                  ),
                ),
                RadioGroup<String>(
                  groupValue: _outcome,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _outcome = value);
                  },
                  child: Column(
                    children: [
                      for (final entry in _fieldOutcomes.entries)
                        RadioListTile<String>(
                          value: entry.key,
                          title: Text(entry.value),
                          contentPadding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h(context)),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'اكتب ملاحظات الكشف الميداني...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text('إضافة صورة (${_photos.length}/5)'),
                ),
                if (_photos.isNotEmpty) ...[
                  SizedBox(height: 8.h(context)),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _photos.length; i++)
                        Chip(
                          label: Text(_photos[i].name),
                          onDeleted: () => setState(() => _photos.removeAt(i)),
                        ),
                    ],
                  ),
                ],
                SizedBox(height: 16.h(context)),
                ElevatedButton(
                  onPressed: () {
                    if (_notesController.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(
                      context,
                      _FieldReportDraft(
                        notes: _notesController.text.trim(),
                        outcome: _outcome,
                        photos: _photos.map((file) => File(file.path)).toList(),
                      ),
                    );
                  },
                  child: const Text('إرسال التقرير'),
                ),
                SizedBox(height: 8.h(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DelegateComplaintTile extends StatelessWidget {
  const _DelegateComplaintTile({
    required this.complaint,
    required this.onInspect,
  });

  final Complaint complaint;
  final VoidCallback onInspect;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final category = complaint.departmentLabel ?? complaint.aiCategory;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h(context)),
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            complaint.displayTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.f(context),
            ),
          ),
          if (category != null && category.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              category,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13.f(context),
              ),
            ),
          ],
          if (complaint.cardLocationDisplay != null) ...[
            SizedBox(height: 4.h(context)),
            Text(
              complaint.cardLocationDisplay!,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.f(context),
              ),
            ),
          ],
          if (complaint.fieldOutcomeLabel != null) ...[
            SizedBox(height: 4.h(context)),
            Text(
              'آخر نتيجة: ${complaint.fieldOutcomeLabel}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12.f(context),
              ),
            ),
          ],
          SizedBox(height: 12.h(context)),
          ElevatedButton.icon(
            onPressed: onInspect,
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
        ],
      ),
    );
  }
}
