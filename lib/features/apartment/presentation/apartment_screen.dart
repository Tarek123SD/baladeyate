import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/form_dropdown_field.dart';
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

/// Floor type Arabic label -> API value (`floor_type`).
const Map<String, String> _floorTypes = {
  'سكني': 'residential',
  'تجاري': 'commercial',
  'مختلط': 'mixed',
};

class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key, this.navigationContext});

  final SurveyNavigationContext? navigationContext;

  @override
  State<ApartmentScreen> createState() => ApartmentScreenState();
}

class ApartmentScreenState extends State<ApartmentScreen> {
  late TextEditingController _waterMeterController;
  late TextEditingController _electricityMeterController;
  late TextEditingController _landlineController;

  bool get _isStandalone => widget.navigationContext != null;

  @override
  void initState() {
    super.initState();
    final unit = _readCurrentUnit();
    _waterMeterController =
        TextEditingController(text: unit?.waterMeter ?? '');
    _electricityMeterController =
        TextEditingController(text: unit?.electricityMeter ?? '');
    _landlineController = TextEditingController(text: unit?.landline ?? '');
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

  void _syncText() {
    if (!_isStandalone) return;
    context.read<BuildingSurveyCubit>().updateCurrentApartment(
          waterMeter: _waterMeterController.text.trim(),
          electricityMeter: _electricityMeterController.text.trim(),
          landline: _landlineController.text.trim(),
        );
  }

  Future<void> _goToPeople() async {
    _syncText();
    final nav = widget.navigationContext!;
    await context.push(
      '/people',
      extra: nav,
    );
  }

  @override
  void dispose() {
    _waterMeterController.dispose();
    _electricityMeterController.dispose();
    _landlineController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final survey = _readSurvey();
    final unit = _readCurrentUnit();
    final floorLocalId = widget.navigationContext?.floorLocalId;
    final floor = floorLocalId != null && survey != null
        ? survey.floorByLocalId(floorLocalId)
        : null;

    final floorTypeLabel = _floorTypes.entries
        .firstWhere(
          (entry) => entry.value == unit?.floorType,
          orElse: () => const MapEntry('سكني', 'residential'),
        )
        .key;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isStandalone) ...[
            InfoCard(
              icon: Icons.layers_outlined,
              title: 'الطابق',
              subtitle: floor != null
                  ? (floor.floorName.isNotEmpty
                      ? floor.floorName
                      : 'الطابق ${floor.floorNumber}')
                  : 'الطابق الحالي',
              iconColor: AppColors.primaryForest,
            ),
            InfoCard(
              icon: Icons.apartment_outlined,
              title: 'المبنى',
              subtitle: survey?.building.name.isNotEmpty == true
                  ? survey!.building.name
                  : 'مسح ميداني',
              iconColor: AppColors.primaryForest,
            ),
          ],
          FormSectionCard(
            title: 'تفاصيل الوحدة',
            badge: _isStandalone ? 'مسح ميداني' : 'قيد الإدخال',
            badgeColor: AppColors.primaryGoldenWheat,
            child: Column(
              children: [
                FormDropdownField(
                  label: 'نوع الوحدة',
                  items: _floorTypes.keys.toList(),
                  value: floorTypeLabel,
                  onChanged: (label) {
                    if (label == null) return;
                    context
                        .read<BuildingSurveyCubit>()
                        .updateCurrentApartment(floorType: _floorTypes[label]);
                  },
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'رقم عداد المياه',
                  hint: 'أدخل رقم عداد المياه',
                  controller: _waterMeterController,
                  prefixIcon: Icons.water_drop_outlined,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'رقم عداد الكهرباء',
                  hint: 'أدخل رقم عداد الكهرباء',
                  controller: _electricityMeterController,
                  prefixIcon: Icons.electric_bolt_outlined,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 18.h(context)),
                FormInputField(
                  label: 'الهاتف الأرضي (اختياري)',
                  hint: 'أدخل رقم الهاتف الأرضي',
                  controller: _landlineController,
                  prefixIcon: Icons.call_outlined,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) => _syncText(),
                ),
                SizedBox(height: 8.h(context)),
                SwitchListTile.adaptive(
                  value: unit?.isSealed ?? false,
                  onChanged: (value) => context
                      .read<BuildingSurveyCubit>()
                      .updateCurrentApartment(isSealed: value),
                  activeThumbColor: AppColors.primaryForest,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'الوحدة مغلقة / مختومة',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.s(context),
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryCharcoal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h(context)),
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
                        onPressed: _goToPeople,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryForest,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h(context)),
                        ),
                        child: const Text('التالي: بيانات الأسرة'),
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
