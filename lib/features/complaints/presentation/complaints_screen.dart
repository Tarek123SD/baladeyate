import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_complaint_input_field.dart';
import 'package:baladeyate/core/widgets/custom_complaint_map_box.dart';
import 'package:baladeyate/core/widgets/custom_complaint_priority_button.dart';
import 'package:baladeyate/core/widgets/custom_complaint_upload_box.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool _isUrgent = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintsCubit>(),
      child: BlocConsumer<ComplaintsCubit, ComplaintsState>(
        listener: (context, state) {
          if (state is ComplaintCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إرسال الشكوى بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/track');
          } else if (state is ComplaintsFailure) {
            // Shown inline in the form.
          }
        },
        builder: (context, state) {
          final isSubmitting = state is ComplaintsLoading;
          final errorMessage =
              state is ComplaintsFailure ? state.message : null;

          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundWhite),
                fit: BoxFit.cover,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _buildAppBar(context),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(16.s(context)),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 700.w(context),
                            ),
                            child: _buildFormCard(
                              context,
                              isSubmitting,
                              errorMessage,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
                context.go('/track');
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
              'تقديم شكوى',
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

  Widget _buildFormCard(
    BuildContext context,
    bool isSubmitting,
    String? errorMessage,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 8.s(context)),
          Center(
            child: Text(
              'تقديم شكوى رسمية',
              style: TextStyle(
                fontSize: 22.f(context),
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
          ),
          SizedBox(height: 6.s(context)),
          Center(
            child: Text(
              'ساعدنا في تحسين الخدمات عبر مشاركة التفاصيل بدقة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.f(context),
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.75),
              ),
            ),
          ),
          SizedBox(height: 18.s(context)),
          _buildSectionCard(
            context: context,
            title: 'درجة الأولوية',
            child: Row(
              children: [
                Expanded(
                  child: CustomComplaintPriorityButton(
                    text: 'طارئ / مستعجل',
                    isActive: _isUrgent,
                    onTap: () => setState(() => _isUrgent = true),
                  ),
                ),
                SizedBox(width: 10.s(context)),
                Expanded(
                  child: CustomComplaintPriorityButton(
                    text: 'اعتيادي',
                    isActive: !_isUrgent,
                    onTap: () => setState(() => _isUrgent = false),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.s(context)),
          _buildSectionCard(
            context: context,
            title: 'موضوع الشكوى',
            child: CustomComplaintInputField(
              controller: _subjectController,
              hint: 'مثال: صيانة الطرق...',
            ),
          ),
          SizedBox(height: 14.s(context)),
          _buildSectionCard(
            context: context,
            title: 'تفاصيل الشكوى',
            child: CustomComplaintInputField(
              controller: _detailsController,
              hint: 'يرجى كتابة وصف دقيق...',
              maxLines: 5,
            ),
          ),
          SizedBox(height: 14.s(context)),
          _buildSectionCard(
            context: context,
            title: 'المرفقات و الصور',
            child: const CustomComplaintUploadBox(),
          ),
          SizedBox(height: 14.s(context)),
          _buildSectionCard(
            context: context,
            title: 'الموقع الجغرافي',
            child: const CustomComplaintMapBox(),
          ),
          SizedBox(height: 18.s(context)),
          if (errorMessage != null) ...[
            _buildErrorSection(
              context,
              message: errorMessage,
              onRetry: () => _submitComplaint(context),
            ),
            SizedBox(height: 14.s(context)),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : () => _submitComplaint(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 13.h(context)),
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
                  : Icon(
                      Icons.send_rounded,
                      size: 18.s(context),
                    ),
              label: Text(
                'إرسال الشكوى',
                style: TextStyle(
                  fontSize: 15.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.s(context)),
        ],
      ),
    );
  }

  void _submitComplaint(BuildContext context) {
    final subject = _subjectController.text.trim();
    final details = _detailsController.text.trim();

    if (details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى كتابة تفاصيل الشكوى')),
      );
      return;
    }

    final description = subject.isEmpty ? details : '$subject\n$details';

    context.read<ComplaintsCubit>().createComplaint(
          description: description,
          isUrgent: _isUrgent,
        );
  }

  Widget _buildErrorSection(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(
          color: AppColors.thirdGoldenWheat.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14.f(context),
              fontWeight: FontWeight.w600,
              color: Colors.black,
              height: 1.5,
            ),
          ),
          SizedBox(height: 14.h(context)),
          SizedBox(
            height: 44.h(context),
            child: OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryForest,
                backgroundColor:
                    AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                side: BorderSide(
                  color: AppColors.primaryForest.withValues(alpha: 0.35),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 18.s(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontSize: 14.f(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(12.s(context)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(14.r(context)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
          SizedBox(height: 10.s(context)),
          child,
        ],
      ),
    );
  }
}
