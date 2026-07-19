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
  const ApartmentScreen({
    super.key,
    this.navigationContext,
    required this.apartmentsCount,
  });

  final SurveyNavigationContext? navigationContext;
  final int apartmentsCount;

  @override
  State<ApartmentScreen> createState() => ApartmentScreenState();
}

class ApartmentScreenState extends State<ApartmentScreen> {
  late List<TextEditingController> _waterMeterControllers;
  late List<TextEditingController> _electricityMeterControllers;
  late List<TextEditingController> _landlineControllers;
  late List<ApartmentUnitDraft> _apartmentDrafts;
  bool _initialized = false;

  bool get _isStandalone => widget.navigationContext != null;

  @override
  void initState() {
    super.initState();
    final survey = _readSurvey();
    if (survey != null) {
      _initializeIfNeeded(survey);
    }
  }

  void _initializeIfNeeded(BuildingSurvey survey) {
    if (_initialized) return;

    final floorLocalId = widget.navigationContext?.floorLocalId;
    final floor = floorLocalId != null
        ? survey.floorByLocalId(floorLocalId)
        : null;

    final existingApts = floor?.apartments ?? [];

    _apartmentDrafts = List.generate(widget.apartmentsCount, (index) {
      if (index < existingApts.length) {
        return existingApts[index];
      } else {
        return ApartmentUnitDraft(
          localId: 'apt_${floorLocalId ?? 'temp'}_$index',
        );
      }
    });

    _waterMeterControllers = _apartmentDrafts
        .map((apt) => TextEditingController(text: apt.waterMeter))
        .toList();
    _electricityMeterControllers = _apartmentDrafts
        .map((apt) => TextEditingController(text: apt.electricityMeter))
        .toList();
    _landlineControllers = _apartmentDrafts
        .map((apt) => TextEditingController(text: apt.landline))
        .toList();

    _initialized = true;
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

  void _syncAllText() {
    if (!_initialized) return;
    for (int i = 0; i < widget.apartmentsCount; i++) {
      _apartmentDrafts[i] = _apartmentDrafts[i].copyWith(
        waterMeter: _waterMeterControllers[i].text.trim(),
        electricityMeter: _electricityMeterControllers[i].text.trim(),
        landline: _landlineControllers[i].text.trim(),
      );
    }
  }

  Future<void> _goToFamily(int index) async {
    _syncAllText();
    final cubit = context.read<BuildingSurveyCubit>();
    await cubit.updateFloorApartments(_apartmentDrafts);
    await cubit.setCurrentApartment(_apartmentDrafts[index]);

    if (!mounted) return;
    final nav = widget.navigationContext!;
    await context.push(
      '/people',
      extra: nav,
    );
  }

  Future<void> _saveAllApartments() async {
    _syncAllText();
    final cubit = context.read<BuildingSurveyCubit>();
    await cubit.updateFloorApartments(_apartmentDrafts);

    final success = await cubit.saveAllFloorApartments(_apartmentDrafts);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ بيانات شقق الطابق بنجاح'),
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      final state = cubit.state;
      if (state is BuildingSurveyFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      for (final controller in _waterMeterControllers) {
        controller.dispose();
      }
      for (final controller in _electricityMeterControllers) {
        controller.dispose();
      }
      for (final controller in _landlineControllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final survey = _readSurvey();
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
          if (_initialized)
            ...List.generate(widget.apartmentsCount, (index) {
              final unit = _apartmentDrafts[index];
              final floorTypeLabel = _floorTypes.entries
                  .firstWhere(
                    (entry) => entry.value == unit.floorType,
                    orElse: () => const MapEntry('سكني', 'residential'),
                  )
                  .key;

              return FormSectionCard(
                title: 'تفاصيل الشقة ${index + 1}',
                badge: unit.isSaved ? 'تم الحفظ' : 'مسح ميداني',
                badgeColor: unit.isSaved ? AppColors.primaryForest : AppColors.primaryGoldenWheat,
                child: Column(
                  children: [
                    FormDropdownField(
                      label: 'نوع الوحدة',
                      items: _floorTypes.keys.toList(),
                      value: floorTypeLabel,
                      onChanged: (label) {
                        if (label == null) return;
                        setState(() {
                          _apartmentDrafts[index] = _apartmentDrafts[index].copyWith(
                            floorType: _floorTypes[label],
                          );
                        });
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
                    ),
                    SizedBox(height: 18.h(context)),
                    FormInputField(
                      label: 'رقم عداد المياه',
                      hint: 'أدخل رقم عداد المياه',
                      controller: _waterMeterControllers[index],
                      prefixIcon: Icons.water_drop_outlined,
                      onChanged: (_) {
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
                    ),
                    SizedBox(height: 18.h(context)),
                    FormInputField(
                      label: 'رقم عداد الكهرباء',
                      hint: 'أدخل رقم عداد الكهرباء',
                      controller: _electricityMeterControllers[index],
                      prefixIcon: Icons.electric_bolt_outlined,
                      onChanged: (_) {
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
                    ),
                    SizedBox(height: 18.h(context)),
                    FormInputField(
                      label: 'الهاتف الأرضي (اختياري)',
                      hint: 'أدخل رقم الهاتف الأرضي',
                      controller: _landlineControllers[index],
                      prefixIcon: Icons.call_outlined,
                      keyboardType: TextInputType.phone,
                      onChanged: (_) {
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
                    ),
                    SizedBox(height: 18.h(context)),
                    FormDropdownField(
                      label: 'حالة الشقة',
                      items: const ['مسكونة', 'فارغة', 'مغلقة', 'قيد الإكساء'],
                      value: unit.status.isEmpty ? 'فارغة' : unit.status,
                      onChanged: (newStatus) {
                        if (newStatus == null) return;
                        setState(() {
                          _apartmentDrafts[index] = _apartmentDrafts[index].copyWith(
                            status: newStatus,
                            isSealed: newStatus == 'مغلقة' ? true : unit.isSealed,
                          );
                        });
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
                    ),
                    SizedBox(height: 8.h(context)),
                    SwitchListTile.adaptive(
                      value: unit.isSealed,
                      onChanged: (value) {
                        setState(() {
                          _apartmentDrafts[index] = _apartmentDrafts[index].copyWith(
                            isSealed: value,
                          );
                        });
                        _syncAllText();
                        context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
                      },
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
                    if (unit.status == 'مسكونة') ...[
                      SizedBox(height: 12.h(context)),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _goToFamily(index),
                          icon: const Icon(Icons.people_outline, color: Colors.white),
                          label: const Text('إضافة بيانات الأسرة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGoldenWheat,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
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
        final survey = switch (state) {
          BuildingSurveyLoaded(:final survey) => survey,
          BuildingSurveyFailure(:final survey) => survey,
          BuildingSurveySaving(:final survey) => survey,
          _ => null,
        };

        if (survey == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _initializeIfNeeded(survey);

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
                        onPressed: isSaving ? null : _saveAllApartments,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryForest,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h(context)),
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
                            : const Text('حفظ شقق الطابق'),
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
