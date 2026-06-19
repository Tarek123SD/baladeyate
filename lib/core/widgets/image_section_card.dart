import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable image section card for displaying images or image placeholders.
class ImageSectionCard extends StatelessWidget {
  const ImageSectionCard({
    super.key,
    required this.label,
    this.imageUrl,
    this.onAddImage,
    this.onViewImage,
  });

  /// Label for the image section
  final String label;

  /// Image URL (if available)
  final String? imageUrl;

  /// Callback when add image button is tapped
  final VoidCallback? onAddImage;

  /// Callback when image is tapped to view
  final VoidCallback? onViewImage;

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
          onTap: imageUrl != null ? onViewImage : onAddImage,
          child: Container(
            height: 180.h(context),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1,
              ),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48.w(context),
                        height: 48.w(context),
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.primaryForest,
                          size: 24.s(context),
                        ),
                      ),
                      SizedBox(height: 12.h(context)),
                      Text(
                        'اضغط لإضافة صورة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 13.s(context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryCharcoal,
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r(context)),
                    ),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(8.w(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r(context)),
                        ),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: AppColors.primaryForest,
                          size: 24.s(context),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
