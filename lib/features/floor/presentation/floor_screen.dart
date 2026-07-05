import 'package:baladeyate/features/delegate/cubits/delegate_survey_cubit/delegate_survey_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/file_upload_section.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';

class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key, this.surveyMode = false});

  final bool surveyMode;

  @override
  State<FloorScreen> createState() => FloorScreenState();
}

class FloorScreenState extends State<FloorScreen> {
  late TextEditingController _floorNumberController;
  late TextEditingController _floorNameController;
  late TextEditingController _apartmentCountController;
  late TextEditingController _floorPlanNumberController;

  DelegateSurveyCubit? _surveyCubit;

  @override
  void initState() {
    super.initState();
    if (widget.surveyMode) {
      _surveyCubit = context.read<DelegateSurveyCubit>();
    }
    final draft = _readDraft();
    _floorNumberController = TextEditingController(text: draft?.floorNumber ?? '4');
    _floorNameController = TextEditingController(text: draft?.floorName ?? '');
    _apartmentCountController =
        TextEditingController(text: draft?.apartmentCount ?? '');
    _floorPlanNumberController =
        TextEditingController(text: draft?.floorPlanNumber ?? '');

    if (widget.surveyMode) {
      for (final controller in [
        _floorNumberController,
        _floorNameController,
        _apartmentCountController,
        _floorPlanNumberController,
      ]) {
        controller.addListener(_syncToCubit);
      }
      _syncToCubit();
    }
  }

  void syncSurveyForm() => _syncToCubit();

  dynamic _readDraft() {
    if (_surveyCubit == null) return null;
    final state = _surveyCubit!.state;
    if (state is DelegateSurveyEditing) return state.draft;
    if (state is DelegateSurveyFailure) return state.draft;
    return null;
  }

  void _syncToCubit() {
    if (_surveyCubit == null) return;
    _surveyCubit!.updateFloor(
          floorNumber: _floorNumberController.text.trim(),
          floorName: _floorNameController.text.trim(),
          apartmentCount: _apartmentCountController.text.trim(),
          floorPlanNumber: _floorPlanNumberController.text.trim(),
        );
  }

  @override
  void dispose() {
    if (widget.surveyMode) {
      for (final controller in [
        _floorNumberController,
        _floorNameController,
        _apartmentCountController,
        _floorPlanNumberController,
      ]) {
        controller.removeListener(_syncToCubit);
      }
    }
    _floorNumberController.dispose();
    _floorNameController.dispose();
    _apartmentCountController.dispose();
    _floorPlanNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.backgroundWhite),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormSectionCard(
              title: 'مواصفات الطابق',
              badge: widget.surveyMode ? 'مسح ميداني' : 'قيد الإدخال',
              badgeColor: AppColors.primaryGoldenWheat,
              child: Column(
                children: [
                  FormInputField(
                    label: 'رقم الطابق',
                    hint: 'مثال: 4',
                    controller: _floorNumberController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 18.h(context)),
                  FormInputField(
                    label: 'اسم الطابق (اختياري)',
                    hint: 'مثال: طابق المزايين',
                    controller: _floorNameController,
                  ),
                  SizedBox(height: 18.h(context)),
                  FormInputField(
                    label: 'عدد الشقق',
                    hint: 'أدخل عدد الوحدات السكنية',
                    controller: _apartmentCountController,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 18.h(context)),
                  FormInputField(
                    label: 'رقم مخطط الطابق',
                    hint: 'أدخل رقم المخطط الفني',
                    controller: _floorPlanNumberController,
                  ),
                ],
              ),
            ),
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى المرتبط',
              subtitle: widget.surveyMode
                  ? (_readDraft()?.buildingName?.isNotEmpty == true
                      ? _readDraft()!.buildingName!
                      : 'مسح ميداني')
                  : 'برج البياسمين',
              iconColor: AppColors.primaryForest,
            ),
            FormSectionCard(
              title: 'مخطط الطابق',
              child: FileUploadSection(
                label: 'رفع المخطط',
                subtitle: 'الحد الأقصى 10 ميجابايت (PDF, JPG, PNG)',
                onUpload: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'سيتم إضافة خاصية اختيار الملفات قريباً',
                      ),
                      backgroundColor: AppColors.primaryForest,
                    ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 12.h(context),
              ),
              padding: EdgeInsets.all(16.w(context)),
              decoration: BoxDecoration(
                color: AppColors.thirdGoldenWheat.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20.r(context)),
                border: Border.all(
                  color: AppColors.secondaryGoldenWheat.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                'الدقة في توثيق بيانات الطابق تضمن سلامة المخططات الإنشائية والبيئية.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.s(context),
                  color: AppColors.primaryForest,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 20.h(context)),
          ],
        ),
        ),
      ],
    );
  }
}
