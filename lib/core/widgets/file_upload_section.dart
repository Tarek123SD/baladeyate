import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable file upload section with drag-and-drop support.
class FileUploadSection extends StatelessWidget {
  const FileUploadSection({
    super.key,
    required this.label,
    required this.subtitle,
    this.fileName,
    this.onUpload,
    this.onRemove,
  });

  /// Section label
  final String label;

  /// Subtitle/instruction text
  final String subtitle;

  /// Currently uploaded file name
  final String? fileName;

  /// Callback when file is selected
  final VoidCallback? onUpload;

  /// Callback when file is removed
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.s(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
          ),
        ),
        SizedBox(height: 10.h(context)),
        GestureDetector(
          onTap: onUpload,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w(context),
              vertical: 32.h(context),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(
                color: const Color(0xFFDCDCDC),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56.w(context),
                  height: 56.w(context),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.file_present_outlined,
                    color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                    size: 28.s(context),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                if (fileName != null)
                  Text(
                    fileName!,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.s(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryForest,
                    ),
                  )
                else
                  Column(
                    children: [
                      Text(
                        'اسحب الملف هنا أو انقر للإضافة',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.s(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryCharcoal,
                        ),
                      ),
                      SizedBox(height: 6.h(context)),
                      Text(
                        subtitle,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.s(context),
                          color: AppColors.secondaryCharcoal.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                if (fileName != null)
                  Padding(
                    padding: EdgeInsets.only(top: 12.h(context)),
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Text(
                        'حذف',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 12.s(context),
                          fontWeight: FontWeight.w600,
                          color: Colors.red[600],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
