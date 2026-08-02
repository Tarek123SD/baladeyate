import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_complex_form_content.dart';
import 'package:baladeyate/features/delegate/presentation/components/building_complex_save_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

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
                          child: BuildingComplexFormContent(
                            survey: survey,
                            buildingNameController: _buildingNameController,
                            realEstateNumberController:
                                _realEstateNumberController,
                            licenseNumberController: _licenseNumberController,
                            floorCountController: _floorCountController,
                            coordinatesController: _coordinatesController,
                            onSyncText: _syncText,
                            onCaptureBuildingPhoto: _captureBuildingPhoto,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                BlocBuilder<BuildingSurveyCubit, BuildingSurveyState>(
                  builder: (context, state) {
                    final isSaving = state is BuildingSurveySaving;
                    return BuildingComplexSaveBar(
                      isSurveyMode: _isSurveyMode,
                      isSaving: isSaving,
                      onSave: _saveBuilding,
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
