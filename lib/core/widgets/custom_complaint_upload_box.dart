import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintUploadBox extends StatefulWidget {
  const CustomComplaintUploadBox({
    super.key,
    this.onFilesChanged,
    this.maxFiles = 5,
  });

  /// Called whenever the selected attachments change.
  final ValueChanged<List<File>>? onFilesChanged;

  /// Maximum number of attachments allowed.
  final int maxFiles;

  @override
  State<CustomComplaintUploadBox> createState() =>
      _CustomComplaintUploadBoxState();
}

class _CustomComplaintUploadBoxState extends State<CustomComplaintUploadBox> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _files = [];

  void _notify() => widget.onFilesChanged?.call(List.unmodifiable(_files));

  Future<void> _pickFrom(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final picked = await _picker.pickMultiImage(imageQuality: 70);
        if (picked.isEmpty) return;
        _addFiles(picked);
      } else {
        final picked = await _picker.pickImage(
          source: source,
          maxWidth: 1600,
          maxHeight: 1600,
          imageQuality: 70,
        );
        if (picked == null) return;
        _addFiles([picked]);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح المعرض/الكاميرا')),
      );
    }
  }

  void _addFiles(List<XFile> picked) {
    final remaining = widget.maxFiles - _files.length;
    if (remaining <= 0) {
      _showMaxReached();
      return;
    }
    final toAdd = picked.take(remaining).map((x) => File(x.path));
    setState(() => _files.addAll(toAdd));
    _notify();
    if (picked.length > remaining) _showMaxReached();
  }

  void _showMaxReached() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('الحد الأقصى ${widget.maxFiles} مرفقات')),
    );
  }

  void _removeAt(int index) {
    setState(() => _files.removeAt(index));
    _notify();
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12.s(context),
              horizontal: 16.s(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44.w(context),
                  height: 4.h(context),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12.s(context)),
                _sheetTile(
                  context,
                  icon: Icons.photo_camera_rounded,
                  label: 'التقاط بالكاميرا',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickFrom(ImageSource.camera);
                  },
                ),
                _sheetTile(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'اختيار من المعرض',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickFrom(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.thirdGoldenWheat,
        child: Icon(icon, color: AppColors.primaryForest),
      ),
      title: Text(
        label,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 15.f(context),
          fontWeight: FontWeight.w600,
          color: AppColors.primaryForest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDropZone(context),
        if (_files.isNotEmpty) ...[
          SizedBox(height: 12.s(context)),
          _buildPreviewGrid(context),
        ],
      ],
    );
  }

  Widget _buildDropZone(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r(context)),
        onTap: _showSourceSheet,
        child: Container(
          height: 140.h(context),
          decoration: BoxDecoration(
            color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14.r(context)),
            border: Border.all(
              color: AppColors.primaryForest.withValues(alpha: 0.35),
              width: 1.4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.s(context)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 28.ic(context),
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 10.s(context)),
                Text(
                  'اضغط لإرفاق صور أو مستندات',
                  style: TextStyle(
                    fontSize: 14.f(context),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 4.s(context)),
                Text(
                  'كاميرا أو معرض (حتى ${widget.maxFiles} ملفات)',
                  style: TextStyle(
                    fontSize: 11.f(context),
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewGrid(BuildContext context) {
    return Wrap(
      spacing: 10.s(context),
      runSpacing: 10.s(context),
      alignment: WrapAlignment.end,
      children: [
        for (int i = 0; i < _files.length; i++)
          _buildThumbnail(context, i),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, int index) {
    final size = 84.s(context);
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r(context)),
          child: Image.file(
            _files[index],
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeAt(index),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.alertRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
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
  }
}
