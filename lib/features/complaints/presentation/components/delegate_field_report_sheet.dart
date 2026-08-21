import 'dart:io';

import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

const fieldReportOutcomes = <String, String>{
  'completed': 'تم الكشف الميداني',
  'needs_follow_up': 'تحتاج جولة ثانية',
  'unreachable': 'تعذر الوصول',
};

class DelegateFieldReportDraft {
  const DelegateFieldReportDraft({
    required this.notes,
    required this.outcome,
    required this.photos,
  });

  final String notes;
  final String outcome;
  final List<File> photos;
}

class DelegateFieldReportSheet extends StatefulWidget {
  const DelegateFieldReportSheet({super.key, required this.complaint});

  final Complaint complaint;

  @override
  State<DelegateFieldReportSheet> createState() =>
      _DelegateFieldReportSheetState();
}

class _DelegateFieldReportSheetState extends State<DelegateFieldReportSheet> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  String _outcome = 'completed';
  final List<XFile> _photos = [];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photos.length >= 5) {
      return;
    }
    final picked = await _picker.pickImage(
      source: source,
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
                SizedBox(height: 8.h(context)),
                Text(
                  widget.complaint.displayTitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13.f(context),
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
                      for (final entry in fieldReportOutcomes.entries)
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(AppIcons.gallery),
                        label: Text('معرض (${_photos.length}/5)'),
                      ),
                    ),
                    if (!kIsWeb) ...[
                      SizedBox(width: 8.w(context)),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickPhoto(ImageSource.camera),
                          icon: const Icon(AppIcons.camera),
                          label: const Text('كاميرا'),
                        ),
                      ),
                    ],
                  ],
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
                      DelegateFieldReportDraft(
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
