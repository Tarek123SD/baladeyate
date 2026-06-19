import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/image_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/core/widgets/workflow_navigation_buttons.dart';
import 'package:baladeyate/core/widgets/workflow_step_indicator.dart';
import 'package:baladeyate/features/apartment/presentation/apartment_screen.dart';
import 'package:baladeyate/features/floor/presentation/floor_screen.dart';
import 'package:baladeyate/features/people/presentation/people_screen.dart';

class BuildingComplexScreen extends StatefulWidget {
  const BuildingComplexScreen({super.key});

  @override
  State<BuildingComplexScreen> createState() => _BuildingComplexScreenState();
}

class _BuildingComplexScreenState extends State<BuildingComplexScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  final List<String> _stepLabelsAr = ['المبنى', 'الطابق', 'الشقة', 'السكان'];

  // Non-const list to support StatefulWidgets (Step 0 shows custom form, so PageView only needs steps 1-3)
  final List<Widget> _screens = [
    FloorScreen(),
    ApartmentScreen(),
    PeopleScreen(),
  ];

  // Building form controllers
  final TextEditingController _buildingNumberController =
      TextEditingController(text: 'BLDG-4022');
  final TextEditingController _buildingNameController =
      TextEditingController(text: 'برج البياسمين');
  final TextEditingController _buildingAddressController =
      TextEditingController();
  final TextEditingController _floorCountController =
      TextEditingController(text: 'مثال: 12');
  String? _buildingTypeValue;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _stepLabelsAr.length, vsync: this);
    _pageController = PageController();
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Only animate PageController if we're not on the building step (step 0)
      if (_tabController.index > 0) {
        _pageController.animateToPage(
          _tabController.index - 1, // PageView index = step - 1
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic,
        );
      }
    }
    setState(() {});
  }

  void _handlePageChange(int index) {
    // PageView index maps to step index + 1 (since step 0 is not in PageView)
    final stepIndex = index + 1;
    if (_tabController.index != stepIndex) {
      _tabController.animateTo(stepIndex);
    }
  }

  void _handleNext() {
    if (_tabController.index < _stepLabelsAr.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
    }
  }

  void _handlePrevious() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    _buildingNumberController.dispose();
    _buildingNameController.dispose();
    _buildingAddressController.dispose();
    _floorCountController.dispose();
    super.dispose();
  }

  Widget _buildBuildingFormContent(BuildContext context) {
    return Column(
      children: [
        FormInputField(
          label: 'رقم المبنى',
          hint: 'أدخل رقم المبنى',
          controller: _buildingNumberController,
          prefixIcon: Icons.lock_outline_rounded,
          readOnly: true,
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
          items: ['سكني', 'تجاري', 'مختلط', 'صناعي', 'آخر'],
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
    final int currentStep = _tabController.index;
    final bool isBuildingStep = currentStep == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Workflow Step Indicator
            WorkflowStepIndicator(
              steps: _stepLabelsAr,
              currentStep: currentStep,
              onStepTapped: (index) {
                _tabController.animateTo(index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                );
              },
            ),
            // Main Content Area
            Expanded(
              child: isBuildingStep
                  ? _buildBuildingStepContent(context)
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: _handlePageChange,
                      itemCount: _screens.length,
                      itemBuilder: (context, index) => _screens[index],
                    ),
            ),
            // Navigation Buttons (for all steps)
            WorkflowNavigationButtons(
              currentStep: currentStep,
              totalSteps: _stepLabelsAr.length,
              onNext: _handleNext,
              onPrevious: _handlePrevious,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingStepContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Building File Card
          FormSectionCard(
            title: 'ملف المبنى',
            badge: 'قيد التفقيش',
            badgeColor: AppColors.primaryGoldenWheat,
            child: _buildBuildingFormContent(context),
          ),
          // Last Inspection Card
          InfoCard(
            icon: Icons.access_time_rounded,
            title: 'آخر تفقيش',
            subtitle: '12 مايو 2023',
            iconColor: AppColors.primaryForest.withValues(alpha: 0.15),
          ),
          // License Status Card
          InfoCard(
            icon: Icons.settings_rounded,
            title: 'حالة الترخيص',
            subtitle: 'سارى المفعول',
            iconColor: AppColors.primaryForest.withValues(alpha: 0.15),
          ),
          SizedBox(height: 16.h(context)),
        ],
      ),
    );
  }
}
