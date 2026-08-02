import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/presentation/components/apartment_form_body.dart';
import 'package:baladeyate/features/delegate/presentation/components/apartment_save_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

  void _onFieldsChanged() {
    _syncAllText();
    context.read<BuildingSurveyCubit>().updateFloorApartments(_apartmentDrafts);
  }

  void _onUnitChanged(int index, ApartmentUnitDraft unit) {
    setState(() {
      _apartmentDrafts[index] = unit;
    });
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

    return ApartmentFormBody(
      isStandalone: _isStandalone,
      survey: survey,
      floor: floor,
      apartmentsCount: widget.apartmentsCount,
      initialized: _initialized,
      apartmentDrafts: _apartmentDrafts,
      waterMeterControllers: _waterMeterControllers,
      electricityMeterControllers: _electricityMeterControllers,
      landlineControllers: _landlineControllers,
      onUnitChanged: _onUnitChanged,
      onFieldsChanged: _onFieldsChanged,
      onAddFamily: _goToFamily,
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
                  ApartmentSaveBar(
                    isSaving: isSaving,
                    onSave: _saveAllApartments,
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
