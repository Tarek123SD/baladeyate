import 'dart:io';

import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable image section card for displaying images or image placeholders.
class ImageSectionCard extends StatelessWidget {
  const ImageSectionCard({
    super.key,
    required this.label,
    this.imageUrl,
    this.localImagePath,
    this.placeholderText = 'اضغط لإضافة صورة',
    this.onAddImage,
    this.onViewImage,
  });

  /// Label for the image section
  final String label;

  /// Image URL (if available)
  final String? imageUrl;

  /// Local file path for a captured/selected image
  final String? localImagePath;

  /// Placeholder text when no image is set
  final String placeholderText;

  /// Callback when add image button is tapped
  final VoidCallback? onAddImage;

  /// Callback when image is tapped to view
  final VoidCallback? onViewImage;

  bool get _hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (localImagePath != null && localImagePath!.isNotEmpty);

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
          onTap: _hasImage ? onViewImage ?? onAddImage : onAddImage,
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
              image: _buildDecorationImage(),
            ),
            child: _hasImage ? _buildImageOverlay(context) : _buildPlaceholder(context),
          ),
        ),
      ],
    );
  }

  DecorationImage? _buildDecorationImage() {
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      final file = File(localImagePath!);
      if (file.existsSync()) {
        return DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        );
      }
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return DecorationImage(
        image: NetworkImage(imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Column(
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w(context)),
          child: Text(
            placeholderText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 13.s(context),
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryCharcoal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageOverlay(BuildContext context) {
    return Container(
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
    );
  }
}
