import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomReceiptUploadBox extends StatelessWidget {
  const CustomReceiptUploadBox({
    super.key,
    required this.selectedImage,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  final File? selectedImage;
  final ValueChanged<File> onImagePicked;
  final VoidCallback onImageRemoved;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        onImagePicked(File(pickedFile.path));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر اختيار الصورة: $e')),
      );
    }
  }

  void _showPickerModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r(context))),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w(context),
              20.h(context),
              20.w(context),
              28.h(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38.w(context),
                    height: 4.h(context),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                Text(
                  'اختيار صورة الإيصال',
                  style: TextStyle(
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryForest,
                  ),
                ),
                SizedBox(height: 16.h(context)),
                // Gallery Option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickImage(context, ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(12.r(context)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w(context),
                        vertical: 14.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r(context)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.s(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primaryForest.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: AppColors.primaryForest,
                              size: 22.ic(context),
                            ),
                          ),
                          SizedBox(width: 14.w(context)),
                          Text(
                            'معرض الصور (الاستوديو)',
                            style: TextStyle(
                              fontSize: 14.5.f(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.grey.shade400,
                            size: 20.ic(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                // Camera Option
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _pickImage(context, ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(12.r(context)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w(context),
                        vertical: 14.h(context),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12.r(context)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.s(context)),
                            decoration: BoxDecoration(
                              color: AppColors.primaryForest.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primaryForest,
                              size: 22.ic(context),
                            ),
                          ),
                          SizedBox(width: 14.w(context)),
                          Text(
                            'التقاط بواسطة الكاميرا',
                            style: TextStyle(
                              fontSize: 14.5.f(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.grey.shade400,
                            size: 20.ic(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'صورة إيصال التحويل / الدفع',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 14.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w(context)),
            Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h(context)),
        if (selectedImage != null)
          Container(
            padding: EdgeInsets.all(12.s(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r(context)),
              border: Border.all(color: AppColors.primaryForest, width: 1.2),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r(context)),
                  child: Image.file(
                    selectedImage!,
                    width: 54.w(context),
                    height: 54.w(context),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تم اختيار الإيصال بنجاح',
                        style: TextStyle(
                          fontSize: 13.5.f(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      SizedBox(height: 2.h(context)),
                      Text(
                        selectedImage!.path.split(RegExp(r'[/\\]')).last,
                        style: TextStyle(
                          fontSize: 11.5.f(context),
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onImageRemoved,
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  tooltip: 'إزالة الصورة',
                ),
              ],
            ),
          )
        else
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPickerModal(context),
              borderRadius: BorderRadius.circular(14.r(context)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 18.h(context),
                  horizontal: 16.w(context),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14.r(context)),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: AppColors.primaryForest,
                      size: 22.ic(context),
                    ),
                    SizedBox(width: 8.w(context)),
                    Text(
                      'إرفاق صورة الإيصال (مطلوب)',
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 13.5.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
