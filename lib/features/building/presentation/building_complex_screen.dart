import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/core/widgets/workflow_navigation_buttons.dart';
import 'package:baladeyate/core/widgets/workflow_step_indicator.dart';
import 'package:baladeyate/features/apartment/presentation/apartment_screen.dart';
import 'package:baladeyate/features/delegate/cubits/delegate_survey_cubit/delegate_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/floor/presentation/floor_screen.dart';
import 'package:baladeyate/features/people/presentation/people_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class BuildingComplexScreen extends StatefulWidget {
  const BuildingComplexScreen({super.key, this.surveyLocation});

  final SurveyLocation? surveyLocation;

  @override
  State<BuildingComplexScreen> createState() => _BuildingComplexScreenState();
}

class _BuildingComplexScreenState extends State<BuildingComplexScreen> {
  final List<String> _stepLabelsAr = ['المبنى', 'الطابق', 'الشقة', 'السكان'];
  int _currentStep = 0;

  final TextEditingController _buildingNumberController =
      TextEditingController();
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingAddressController =
      TextEditingController();
  final TextEditingController _floorCountController = TextEditingController();
  TextEditingController? _coordinatesController;
  String? _buildingTypeValue;

  final GlobalKey<FloorScreenState> _floorKey = GlobalKey<FloorScreenState>();
  final GlobalKey<ApartmentScreenState> _apartmentKey =
      GlobalKey<ApartmentScreenState>();
  final GlobalKey<PeopleScreenState> _peopleKey =
      GlobalKey<PeopleScreenState>();

  DelegateSurveyCubit? _surveyCubit;

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
    }

    if (_isSurveyMode) {
      _surveyCubit = context.read<DelegateSurveyCubit>();
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraftIntoForm());
    }
  }

  void _loadDraftIntoForm() {
    if (!mounted || _surveyCubit == null) return;
    final state = _surveyCubit!.state;
    final draft = switch (state) {
      DelegateSurveyEditing(:final draft) => draft,
      DelegateSurveyFailure(:final draft) => draft,
      _ => null,
    };
    if (draft == null) return;

    _buildingNumberController.text = draft.buildingNumber;
    _buildingNameController.text = draft.buildingName;
    _buildingAddressController.text = draft.buildingAddress;
    _floorCountController.text = draft.floorCount;
    setState(() => _buildingTypeValue = draft.buildingType);
  }

  @override
  void dispose() {
    _coordinatesController?.dispose();
    _buildingNumberController.dispose();
    _buildingNameController.dispose();
    _buildingAddressController.dispose();
    _floorCountController.dispose();
    super.dispose();
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _stepLabelsAr.length || index == _currentStep) {
      return;
    }
    if (_isSurveyMode) {
      _syncAllSurveySteps();
    }
    setState(() => _currentStep = index);
  }

  void _syncBuildingStep() {
    if (_surveyCubit == null) return;
    _surveyCubit!.updateBuilding(
      buildingNumber: _buildingNumberController.text.trim(),
      buildingName: _buildingNameController.text.trim(),
      buildingAddress: _buildingAddressController.text.trim(),
      floorCount: _floorCountController.text.trim(),
      buildingType: _buildingTypeValue,
    );
  }

  void _syncAllSurveySteps() {
    if (!_isSurveyMode) return;
    _syncBuildingStep();
    _floorKey.currentState?.syncSurveyForm();
    _apartmentKey.currentState?.syncSurveyForm();
    _peopleKey.currentState?.syncSurveyForm();
  }

  Future<void> _handleNext() async {
    if (_currentStep < _stepLabelsAr.length - 1) {
      _goToStep(_currentStep + 1);
      return;
    }

    if (_isSurveyMode) {
      _syncAllSurveySteps();
      await _submitSurvey();
    }
  }

  void _handlePrevious() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    }
  }

  Future<void> _submitSurvey() async {
    final cubit = _surveyCubit;
    if (cubit == null) return;

    final result = await cubit.submitSurvey();

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ بيانات المسح بنجاح')),
      );
      context.go('/tasks');
      return;
    }

    final state = cubit.state;
    if (state is DelegateSurveyFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _buildBuildingFormContent(BuildContext context) {
    return Column(
      children: [
        if (_coordinatesController != null) ...[
          FormInputField(
            label: 'إحداثيات النقطة',
            hint: _coordinatesController!.text,
            controller: _coordinatesController,
            prefixIcon: Icons.pin_drop_outlined,
            readOnly: true,
          ),
          SizedBox(height: 18.h(context)),
        ],
        FormInputField(
          label: 'رقم المبنى',
          hint: 'أدخل رقم المبنى',
          controller: _buildingNumberController,
          prefixIcon: Icons.lock_outline_rounded,
          readOnly: !_isSurveyMode,
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'اسم المبنى',
          hint: 'أدخل اسم المبنى',
          controller: _buildingNameController,
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'عنوان المبنى',
          hint: 'أدخل اسم الشارع المنطقة...',
          controller: _buildingAddressController,
          prefixIcon: Icons.location_on_outlined,
        ),
        SizedBox(height: 18.h(context)),
        FormInputField(
          label: 'عدد الطوابق',
          hint: 'مثال: 12',
          controller: _floorCountController,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 18.h(context)),
        FormDropdownField(
          label: 'نوع البناء',
          items: const ['سكني', 'تجاري', 'مختلط', 'صناعي', 'آخر'],
          value: _buildingTypeValue,
          onChanged: (value) => setState(() => _buildingTypeValue = value),
        ),
        SizedBox(height: 18.h(context)),
        ImageSectionCard(
          label: 'الصورة الجوية',
          onAddImage: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('سيتم إضافة خاصية اختيار الصور قريباً'),
                backgroundColor: AppColors.primaryForest,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _stepLabelsAr.length - 1;

    return BlocListener<DelegateSurveyCubit, DelegateSurveyState>(
      listener: (context, state) {},
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
          ),
          body: SafeArea(
            child: Column(
              children: [
                WorkflowStepIndicator(
                  steps: _stepLabelsAr,
                  currentStep: _currentStep,
                  onStepTapped: _goToStep,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      _buildBuildingStepContent(context),
                      FloorScreen(
                        key: _floorKey,
                        surveyMode: _isSurveyMode,
                      ),
                      ApartmentScreen(
                        key: _apartmentKey,
                        surveyMode: _isSurveyMode,
                      ),
                      PeopleScreen(
                        key: _peopleKey,
                        surveyMode: _isSurveyMode,
                      ),
                    ],
                  ),
                ),
                BlocBuilder<DelegateSurveyCubit, DelegateSurveyState>(
                  builder: (context, state) {
                    final isSubmitting = state is DelegateSurveySubmitting;
                    return WorkflowNavigationButtons(
                      currentStep: _currentStep,
                      totalSteps: _stepLabelsAr.length,
                      onNext: _handleNext,
                      onPrevious: _handlePrevious,
                      isNextLoading: isSubmitting,
                      nextLabel: isLastStep && _isSurveyMode
                          ? 'حفظ وإنهاء'
                          : 'التالي',
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

  Widget _buildBuildingStepContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FormSectionCard(
            title: 'ملف المبنى',
            badge: _isSurveyMode ? 'مسح ميداني' : 'قيد التفقيش',
            badgeColor: AppColors.primaryGoldenWheat,
            child: _buildBuildingFormContent(context),
          ),
          InfoCard(
            icon: Icons.access_time_rounded,
            title: 'آخر تفقيش',
            subtitle: '12 مايو 2023',
            iconColor: AppColors.primaryForest,
          ),
          InfoCard(
            icon: Icons.settings_rounded,
            title: 'حالة الترخيص',
            subtitle: 'سارى المفعول',
            iconColor: AppColors.primaryForest,
          ),
          SizedBox(height: 16.h(context)),
        ],
      ),
    );
  }
}
