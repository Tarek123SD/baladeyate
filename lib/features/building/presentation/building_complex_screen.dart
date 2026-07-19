import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Ownership type Arabic label -> API value (`ownership_type`).
const Map<String, String> _ownershipTypes = {
  'ملكية خاصة': 'private',
  'حكومي': 'government',
  'وقف': 'endowment',
};

class BuildingComplexScreen extends StatefulWidget {
  const BuildingComplexScreen({super.key, this.surveyLocation});

  final SurveyLocation? surveyLocation;

  @override
  State<BuildingComplexScreen> createState() => _BuildingComplexScreenState();
}

class _BuildingComplexScreenState extends State<BuildingComplexScreen> {
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _realEstateNumberController =
      TextEditingController();
  final TextEditingController _licenseNumberController =
      TextEditingController();
  final TextEditingController _floorCountController = TextEditingController();
  TextEditingController? _coordinatesController;
  final ImagePicker _imagePicker = ImagePicker();

  bool _hydratedFromSurvey = false;

  bool get _isSurveyMode => widget.surveyLocation != null;

  @override
  void initState() {
    super.initState();

    final location = widget.surveyLocation;
    if (location != null) {
      _coordinatesController = TextEditingController(
        text:
            '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraftIntoForm());
    }
  }

  BuildingSurvey? _surveyFromState(BuildingSurveyState state) {
    return switch (state) {
      BuildingSurveyLoaded(:final survey) => survey,
      BuildingSurveyFailure(:final survey) => survey,
      BuildingSurveySaving(:final survey) => survey,
      _ => null,
    };
  }

  void _loadDraftIntoForm() {
    if (!mounted || _hydratedFromSurvey) return;
    final survey = _surveyFromState(context.read<BuildingSurveyCubit>().state);
    if (survey == null) return;

    final building = survey.building;
    _buildingNameController.text = building.name;
    _realEstateNumberController.text = building.realEstateNumber;
    _licenseNumberController.text = building.licenseNumber;
    _floorCountController.text = building.totalFloors;
    _hydratedFromSurvey = true;
  }

  @override
  void dispose() {
    _coordinatesController?.dispose();
    _buildingNameController.dispose();
    _realEstateNumberController.dispose();
    _licenseNumberController.dispose();
    _floorCountController.dispose();
    super.dispose();
  }

  void _syncText() {
    context.read<BuildingSurveyCubit>().updateBuilding(
          name: _buildingNameController.text.trim(),
          realEstateNumber: _realEstateNumberController.text.trim(),
          licenseNumber: _licenseNumberController.text.trim(),
          totalFloors: _floorCountController.text.trim(),
        );
  }

  Future<void> _captureBuildingPhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 70,
      );
      if (picked == null || !mounted) return;

      context
          .read<BuildingSurveyCubit>()
          .updateBuilding(buildingImagePath: picked.path);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم التقاط صورة المبنى')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر فتح الكاميرا: $error')),
      );
    }
  }

  Future<void> _saveBuilding() async {
    _syncText();
    final cubit = context.read<BuildingSurveyCubit>();
    final success = await cubit.saveBuilding();

    if (!mounted) return;

    if (success) {
      final pinId = widget.surveyLocation!.pinId;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ بيانات المبنى بنجاح')),
      );
      sl<DailyTasksCubit>().refreshDashboard();
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/building/$pinId');
      }
      return;
    }

    final state = cubit.state;
    if (state is BuildingSurveyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _buildBuildingFormContent(
    BuildContext context,
    BuildingSurvey? survey,
  ) {
    final building = survey?.building;
    final ownershipLabel = _ownershipTypes.entries
        .firstWhere(
          (entry) => entry.value == building?.ownershipType,
          orElse: () => const MapEntry('', ''),
        )
        .key;

    return Column(
      children: [
        if (_coordinatesController != null) ...[
          FormInputField(
            label: 'إحداثيات النقطة',
            hint: 'خط العرض، خط الطول',
            controller: _coordinatesController,
            prefixIcon: Icons.pin_drop_outlined,
            readOnly: true,
          ),
          SizedBox(height: 18.h(context)),
        ],
        FormInputField(
          label: 'اسم المبنى',
          hint: 'أدخل اسم المبنى',
          controller: _buildingNameController,
          onChanged: (_) => _syncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'الرقم العقاري',
          hint: 'أدخل الرقم العقاري للمبنى',
          controller: _realEstateNumberController,
          prefixIcon: Icons.numbers_outlined,
          onChanged: (_) => _syncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'رقم الرخصة',
          hint: 'أدخل رقم رخصة البناء',
          controller: _licenseNumberController,
          prefixIcon: Icons.assignment_outlined,
          onChanged: (_) => _syncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'عدد الطوابق',
          hint: 'مثال: 12',
          controller: _floorCountController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _syncText(),
        ),
        SizedBox(height: 18.h(context)),
        FormDropdownField(
          label: 'نوع الملكية',
          items: _ownershipTypes.keys.toList(),
          value: ownershipLabel.isEmpty ? null : ownershipLabel,
          onChanged: (label) {
            if (label == null) return;
            context.read<BuildingSurveyCubit>().updateBuilding(
                  ownershipType: _ownershipTypes[label],
                );
          },
        ),
        SizedBox(height: 8.h(context)),
        _buildSwitch(
          context,
          label: 'يوجد قبو',
          value: building?.hasBasement ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(hasBasement: value),
        ),
        _buildSwitch(
          context,
          label: 'يوجد كراج',
          value: building?.hasGarage ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(hasGarage: value),
        ),
        _buildSwitch(
          context,
          label: 'مبنى مخالف / غير مرخّص',
          value: building?.isIllegal ?? false,
          onChanged: (value) => context
              .read<BuildingSurveyCubit>()
              .updateBuilding(isIllegal: value),
        ),
        SizedBox(height: 18.h(context)),
        ImageSectionCard(
          label: 'صورة المبنى',
          localImagePath: building?.buildingImagePath,
          placeholderText: 'التقط صورة للمبنى من الكاميرا',
          onAddImage: _captureBuildingPhoto,
          onViewImage: _captureBuildingPhoto,
        ),
      ],
    );
  }

  Widget _buildSwitch(
    BuildContext context, {
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primaryForest,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 13.s(context),
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryCharcoal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BuildingSurveyCubit, BuildingSurveyState>(
      listener: (context, state) {
        if (state is BuildingSurveyLoaded) {
          _loadDraftIntoForm();
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
          appBar: const CustomAppBar(
            showBackButton: true,
            showSettings: false,
            showNotifications: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child:
                        BlocBuilder<BuildingSurveyCubit, BuildingSurveyState>(
                      buildWhen: (previous, current) {
                        final prevSurvey = _surveyFromState(previous);
                        final currSurvey = _surveyFromState(current);
                        return previous.runtimeType != current.runtimeType ||
                            prevSurvey?.building != currSurvey?.building;
                      },
                      builder: (context, state) {
                        final survey = _surveyFromState(state);
                        return FormSectionCard(
                          title: 'ملف المبنى',
                          badge: _isSurveyMode ? 'مسح ميداني' : 'قيد التفقيش',
                          badgeColor: AppColors.primaryGoldenWheat,
                          child: _buildBuildingFormContent(context, survey),
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<BuildingSurveyCubit, BuildingSurveyState>(
                  builder: (context, state) {
                    final isSaving = state is BuildingSurveySaving;
                    return Padding(
                      padding: EdgeInsets.all(16.w(context)),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isSurveyMode && !isSaving ? _saveBuilding : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: 14.h(context),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14.r(context)),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('حفظ المبنى'),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
