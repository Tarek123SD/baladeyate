import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/file_upload_section.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorScreen extends StatefulWidget {
  const FloorScreen({super.key, this.navigationContext});

  final SurveyNavigationContext? navigationContext;

  @override
  State<FloorScreen> createState() => FloorScreenState();
}

class FloorScreenState extends State<FloorScreen> {
  late TextEditingController _floorNumberController;
  late TextEditingController _floorNameController;
  late TextEditingController _apartmentCountController;
  late TextEditingController _floorPlanNumberController;

  bool get _isStandalone => widget.navigationContext != null;

  @override
  void initState() {
    super.initState();
    final floor = _readFloorDraft();
    _floorNumberController =
        TextEditingController(text: floor?.floorNumber ?? '');
    _floorNameController = TextEditingController(text: floor?.floorName ?? '');
    _apartmentCountController =
        TextEditingController(text: floor?.expectedApartmentCount ?? '');
    _floorPlanNumberController =
        TextEditingController(text: floor?.floorPlanNumber ?? '');
  }

  FloorDraft? _readFloorDraft() {
    if (!_isStandalone) return null;
    final state = context.read<BuildingSurveyCubit>().state;
    final survey = switch (state) {
      BuildingSurveyLoaded(:final survey) => survey,
      BuildingSurveyFailure(:final survey) => survey,
      BuildingSurveySaving(:final survey) => survey,
      _ => null,
    };
    if (survey == null) return null;

    final floorLocalId = widget.navigationContext!.floorLocalId;
    if (floorLocalId == null) return null;
    return survey.floorByLocalId(floorLocalId);
  }

  BuildingSurvey? _readSurvey() {
    final state = context.read<BuildingSurveyCubit>().state;
    return switch (state) {
      BuildingSurveyLoaded(:final survey) => survey,
      BuildingSurveyFailure(:final survey) => survey,
      BuildingSurveySaving(:final survey) => survey,
      _ => null,
    };
  }

  Future<void> _saveFloor() async {
    final nav = widget.navigationContext!;
    await context.read<BuildingSurveyCubit>().saveFloor(
          floorLocalId: nav.isNewFloor ? null : nav.floorLocalId,
          floorNumber: _floorNumberController.text.trim(),
          floorName: _floorNameController.text.trim(),
          expectedApartmentCount: _apartmentCountController.text.trim(),
          floorPlanNumber: _floorPlanNumberController.text.trim(),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ بيانات الطابق')),
    );
    context.go('/building/${nav.pinId}');
  }

  @override
  void dispose() {
    _floorNumberController.dispose();
    _floorNameController.dispose();
    _apartmentCountController.dispose();
    _floorPlanNumberController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final survey = _readSurvey();
    final buildingName = survey?.building.name ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormSectionCard(
            title: 'مواصفات الطابق',
            badge: _isStandalone ? 'مسح ميداني' : 'قيد الإدخال',
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
            subtitle: buildingName.isNotEmpty ? buildingName : 'مسح ميداني',
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
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStandalone) {
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
          _buildForm(context),
        ],
      );
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(
          showBackButton: true,
          showSettings: false,
          showNotifications: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildForm(context)),
              Padding(
                padding: EdgeInsets.all(16.w(context)),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveFloor,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryForest,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                    ),
                    child: const Text('حفظ الطابق'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
