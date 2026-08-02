import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class SignupIdentityUploadField extends StatelessWidget {
  const SignupIdentityUploadField({
    super.key,
    required this.identityImage,
    required this.onTap,
  });

  final File? identityImage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final r = 12.r(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h(context)),
        decoration: BoxDecoration(
          border: Border.all(
            color: identityImage == null ? Colors.grey[300]! : AppColors.green,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(r),
          color: identityImage == null
              ? Colors.grey[50]
              : Colors.green.withValues(alpha: 0.05),
        ),
        child: identityImage != null
            ? Column(
                children: [
                  Container(
                    width: 60.s(context),
                    height: 60.s(context),
                    decoration: const BoxDecoration(
                      color: Color(0xFF90EE90),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: AppColors.primaryForest,
                      size: 32.s(context),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'تم تحميل الصورة بنجاح',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryForest,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    identityImage!.path.split('/').last,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 60.s(context),
                    height: 60.s(context),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD699),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primaryForest,
                      size: 32.s(context),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Text(
                    'اضغط هنا لرفع صورة الهوية',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryForest,
                        ),
                    textDirection: TextDirection.rtl,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'PNG / JPG / JPEG',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryForest,
                        ),
                  ),
                ],
              ),
      ),
    );
  }
}
