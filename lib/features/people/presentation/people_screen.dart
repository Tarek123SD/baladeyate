import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
import 'package:baladeyate/core/widgets/form_input_field.dart';
import 'package:baladeyate/core/widgets/form_section_card.dart';
import 'package:baladeyate/core/widgets/info_card.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Health status Arabic label -> API value (`health_status`).
const Map<String, String> _healthStatuses = {
  'جيدة': 'good',
  'متوسطة': 'medium',
  'سيئة': 'poor',
};

/// Living/economic status Arabic label -> API value (`living_status`).
const Map<String, String> _livingStatuses = {
  'جيدة': 'good',
  'متوسطة': 'medium',
  'منخفضة': 'poor',
};

/// Occupancy type Arabic label -> API value (`occupancy_type`).
const Map<String, String> _occupancyTypes = {
  'ملك': 'owner',
  'إيجار': 'rent',
};

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key, this.navigationContext});

  final SurveyNavigationContext? navigationContext;

  @override
  State<PeopleScreen> createState() => PeopleScreenState();
}

class PeopleScreenState extends State<PeopleScreen> {
  late TextEditingController _familyBookController;
  late TextEditingController _unemployedCountController;
  late TextEditingController _studentsCountController;
  late TextEditingController _familyMembersCountController;
  late TextEditingController _residentsCountController;
  late TextEditingController _compositionController;

  bool get _isStandalone => widget.navigationContext != null;

  @override
  void initState() {
    super.initState();
    final unit = _readCurrentUnit();
    _familyBookController = TextEditingController(text: unit?.familyBook ?? '');
    _unemployedCountController =
        TextEditingController(text: unit?.unemployedCount ?? '');
    _studentsCountController =
        TextEditingController(text: unit?.studentsCount ?? '');
    _familyMembersCountController =
        TextEditingController(text: unit?.familyMembersCount ?? '');
    _residentsCountController =
        TextEditingController(text: unit?.residentsCount ?? '');
    _compositionController =
        TextEditingController(text: unit?.composition ?? '');
  }

  ApartmentUnitDraft? _readCurrentUnit() {
    if (!_isStandalone) return null;
    final state = context.read<BuildingSurveyCubit>().state;
    return switch (state) {
      BuildingSurveyLoaded(:final survey) => survey.currentApartment,
      BuildingSurveyFailure(:final survey) => survey.currentApartment,
      BuildingSurveySaving(:final survey) => survey.currentApartment,
      _ => null,
    };
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

  bool get _isDataVerified => _readCurrentUnit()?.isDataVerified ?? false;

  void _syncText() {
    if (!_isStandalone) return;
    context.read<BuildingSurveyCubit>().updateCurrentFamily(
          familyBook: _familyBookController.text.trim(),
          unemployedCount: _unemployedCountController.text.trim(),
          studentsCount: _studentsCountController.text.trim(),
          familyMembersCount: _familyMembersCountController.text.trim(),
          residentsCount: _residentsCountController.text.trim(),
          composition: _compositionController.text.trim(),
        );
  }

  Future<void> _pickAidDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    final formatted =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    context.read<BuildingSurveyCubit>().updateCurrentFamily(
          lastAidDate: formatted,
        );
  }

  Future<void> _saveUnit() async {
    _syncText();
    final cubit = context.read<BuildingSurveyCubit>();
    final wasUpdate = _readCurrentUnit()?.isSaved == true;
    final success = await cubit.saveApartmentUnit();

    if (!mounted) return;

    if (success) {
      final nav = widget.navigationContext!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasUpdate
                ? 'تم تحديث الشقة وبيانات الأسرة بنجاح'
                : 'تم حفظ الشقة وبيانات الأسرة بنجاح',
          ),
        ),
      );
      final navigator = Navigator.of(context);
      sl<DailyTasksCubit>().refreshDashboard();
      if (navigator.canPop()) {
        navigator.pop();
        if (navigator.canPop()) {
          navigator.pop();
        }
      } else {
        if (mounted) {
          context.go('/building/${nav.pinId}/floor/${nav.floorLocalId}');
        }
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
  void dispose() {
    _familyBookController.dispose();
    _unemployedCountController.dispose();
    _studentsCountController.dispose();
    _familyMembersCountController.dispose();
    _residentsCountController.dispose();
    _compositionController.dispose();
    super.dispose();
  }

  String _labelForValue(Map<String, String> map, String? value, String fallback) {
    return map.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => MapEntry(fallback, map[fallback] ?? ''),
        )
        .key;
  }

  Widget _buildForm(BuildContext context) {
    final survey = _readSurvey();
    final unit = _readCurrentUnit();
    final floorLocalId = widget.navigationContext?.floorLocalId;
    final floor = floorLocalId != null && survey != null
        ? survey.floorByLocalId(floorLocalId)
        : null;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isStandalone) ...[
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: survey?.building.name.isNotEmpty == true
                  ? survey!.building.name
                  : 'مسح ميداني',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: floor != null
                  ? (floor.floorName.isNotEmpty
                      ? floor.floorName
                      : 'الطابق ${floor.floorNumber}')
                  : '—',
              iconColor: AppColors.primaryForest,
            ),
          ],
          FormSectionCard(
            title: 'بيانات الأسرة',
            badge: 'تسجيل الوحدة',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormInputField(
                  label: 'رقم دفتر العائلة',
                  hint: 'أدخل رقم دفتر العائلة',
                  controller: _familyBookController,
                  prefixIcon: Icons.menu_book_outlined,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'الحالة الصحية',
                  items: _healthStatuses.keys.toList(),
                  value: _labelForValue(
                    _healthStatuses,
                    unit?.healthStatus,
                    'جيدة',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          healthStatus: _healthStatuses[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'الحالة المعيشية',
                  items: _livingStatuses.keys.toList(),
                  value: _labelForValue(
                    _livingStatuses,
                    unit?.livingStatus,
                    'متوسطة',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          livingStatus: _livingStatuses[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormDropdownField(
                  label: 'نوع الإشغال',
                  items: _occupancyTypes.keys.toList(),
                  value: _labelForValue(
                    _occupancyTypes,
                    unit?.occupancyType,
                    'ملك',
                  ),
                  onChanged: (label) {
                    if (label == null) return;
                    context.read<BuildingSurveyCubit>().updateCurrentFamily(
                          occupancyType: _occupancyTypes[label],
                        );
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد العاطلين عن العمل',
                  hint: 'مثال: 1',
                  controller: _unemployedCountController,
                  prefixIcon: Icons.work_off_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد الطلاب',
                  hint: 'مثال: 2',
                  controller: _studentsCountController,
                  prefixIcon: Icons.school_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد أفراد العائلة',
                  hint: 'أدخل عدد أفراد العائلة',
                  controller: _familyMembersCountController,
                  prefixIcon: Icons.groups_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'عدد القاطنين الفعلي',
                  hint: 'أدخل عدد القاطنين الفعلي',
                  controller: _residentsCountController,
                  prefixIcon: Icons.home_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'تكوين الأسرة',
                  hint: 'مثال: أب، أم، 3 أبناء',
                  controller: _compositionController,
                  prefixIcon: Icons.account_tree_outlined,
                  maxLines: 3,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                _buildAidDateField(context, unit?.lastAidDate ?? ''),
                SizedBox(height: 24.h(context)),
                _buildVerificationBox(context),
              ],
            ),
          ),
          SizedBox(height: 20.h(context)),
        ],
      ),
    );
  }

  Widget _buildAidDateField(BuildContext context, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'تاريخ آخر مساعدة (اختياري)',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.s(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
          ),
        ),
        SizedBox(height: 10.h(context)),
        InkWell(
          onTap: _pickAidDate,
          borderRadius: BorderRadius.circular(12.r(context)),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w(context),
              vertical: 16.h(context),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r(context)),
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20.s(context),
                  color: Colors.grey[600],
                ),
                SizedBox(width: 12.w(context)),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'اختر التاريخ' : value,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.f(context),
                      color: value.isEmpty ? Colors.grey[600] : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w(context)),
      decoration: BoxDecoration(
        color: AppColors.thirdGoldenWheat.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12.r(context)),
        border: Border.all(
          color: AppColors.secondaryGoldenWheat.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _isDataVerified,
              onChanged: (value) => context
                  .read<BuildingSurveyCubit>()
                  .updateCurrentFamily(isDataVerified: value ?? false),
              activeColor: AppColors.primaryForest,
              side: BorderSide(
                color: AppColors.primaryForest,
                width: 1.5,
              ),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Text(
              'أقر بصحة البيانات المسجلة أعلاه وبأن كافة المعلومات تعكس الواقع الفعلي للأسرة في الوحدة السكنية المحددة.',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 12.s(context),
                color: AppColors.primaryForest,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingSurveyCubit, BuildingSurveyState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
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

        final isSaving = state is BuildingSurveySaving;
        final isUpdate = _readCurrentUnit()?.isSaved == true;
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
                        onPressed: isSaving ? null : _saveUnit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryForest,
                          foregroundColor: Colors.white,
                          padding:
                              EdgeInsets.symmetric(vertical: 14.h(context)),
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
                            : Text(
                                isUpdate
                                    ? 'تحديث الشقة وبيانات الأسرة'
                                    : 'حفظ الشقة وبيانات الأسرة',
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
    );
  }
}
