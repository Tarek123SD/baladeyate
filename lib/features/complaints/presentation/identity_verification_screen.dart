import 'dart:io';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_cubit.dart';
import 'package:baladeyate/features/profile/cubits/profile_cubit/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/routes/auth_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({
    super.key,
    required this.promptText,
    this.preferCamera = false,
    this.showAppBar = true,
    this.initialNationalId,
  });

  final String promptText;
  final bool preferCamera;
  final bool showAppBar;
  final String? initialNationalId;

  @override
  State<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  late final TextEditingController _nationalIdController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nationalIdController = TextEditingController(
      text: widget.initialNationalId ?? '',
    );
  }

  @override
  void dispose() {
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileVerificationSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال طلب توثيق الهوية'),
                backgroundColor: Colors.green,
              ),
            );
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/complains');
            }
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.backgroundWhite),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: widget.showAppBar ? _buildAppBar(context) : null,
            body: SafeArea(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType ||
                    (previous is ProfileLoaded &&
                        current is ProfileLoaded &&
                        previous.identityImage != current.identityImage) ||
                    (previous is ProfileVerificationDraft &&
                        current is ProfileVerificationDraft &&
                        previous.identityImage != current.identityImage),
                builder: (context, state) {
                  final isSubmitting = state is ProfileLoading;
                  final identityImage =
                      context.read<ProfileCubit>().identityImage;

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(20.s(context)),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 560.w(context)),
                        child: _buildForm(
                          context,
                          isSubmitting,
                          identityImage,
                        ),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      automaticallyImplyLeading: false,
      title: Row(
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                final authState = sl<AuthCubit>().state;
                final home = authState is AuthSuccess
                    ? homeRouteFor(authState.user)
                    : '/login';
                context.go(home);
              }
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryForest,
              size: 20.ic(context),
            ),
            padding: EdgeInsets.zero,
          ),
          Expanded(
            child: Text(
              'توثيق الهوية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryForest,
                fontSize: 20.f(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 48.s(context)),
        ],
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    bool isSubmitting,
    File? identityImage,
  ) {
    return Container(
      padding: EdgeInsets.all(20.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18.r(context)),
        border: Border.all(
          color: AppColors.secondaryCharcoal.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 56.s(context),
            color: AppColors.primaryForest,
          ),
          SizedBox(height: 16.h(context)),
          Text(
            widget.promptText,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16.f(context),
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryCharcoal,
              height: 1.6,
            ),
          ),
          SizedBox(height: 24.h(context)),
          Text(
            'الرقم الوطني',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          CustomComplaintInputField(
            controller: _nationalIdController,
            hint: 'أدخل الرقم الوطني (11 رقم)',
          ),
          SizedBox(height: 20.h(context)),
          Text(
            'صورة الهوية',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 8.h(context)),
          _buildImagePicker(context),
          if (identityImage != null) ...[
            SizedBox(height: 12.h(context)),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r(context)),
              child: Image.file(
                identityImage,
                height: 160.h(context),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          SizedBox(height: 24.h(context)),
          SizedBox(
            height: 48.h(context),
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : () => _submit(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r(context)),
                ),
              ),
              icon: isSubmitting
                  ? SizedBox(
                      width: 18.s(context),
                      height: 18.s(context),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(Icons.upload_rounded, size: 20.s(context)),
              label: Text(
                'إرسال طلب التوثيق',
                style: TextStyle(
                  fontSize: 15.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryForest,
              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
              side: BorderSide(
                color: widget.preferCamera
                    ? AppColors.primaryForest
                    : AppColors.primaryForest.withValues(alpha: 0.35),
                width: widget.preferCamera ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
            ),
            icon: Icon(Icons.camera_alt_outlined, size: 20.s(context)),
            label: Text(
              'التقاط بالكاميرا',
              style: TextStyle(
                fontSize: 13.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.s(context)),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryForest,
              padding: EdgeInsets.symmetric(vertical: 12.h(context)),
              side: BorderSide(
                color: AppColors.primaryForest.withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
            ),
            icon: Icon(Icons.photo_library_outlined, size: 20.s(context)),
            label: Text(
              'من المعرض',
              style: TextStyle(
                fontSize: 13.f(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 70,
    );
    if (picked != null) {
      if (!mounted) return;
      context.read<ProfileCubit>().setIdentityImage(File(picked.path));
    }
  }

  Future<void> _submit(BuildContext context) async {
    final nationalId = _nationalIdController.text.trim();
    final identityImage = context.read<ProfileCubit>().identityImage;

    if (nationalId.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الرقم الوطني المكوّن من 11 رقم')),
      );
      return;
    }

    if (identityImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إرفاق صورة الهوية')),
      );
      return;
    }

    await context.read<ProfileCubit>().verifyIdentity(
          nationalId: nationalId,
          identityImage: identityImage,
        );
  }
}
