import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_form_body.dart';
import 'package:baladeyate/features/delegate/presentation/components/floor_save_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    sl<DailyTasksCubit>().refreshDashboard();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/building/${nav.pinId}');
    }
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

    return FloorFormBody(
      isStandalone: _isStandalone,
      buildingName: buildingName,
      floorNumberController: _floorNumberController,
      floorNameController: _floorNameController,
      apartmentCountController: _apartmentCountController,
      floorPlanNumberController: _floorPlanNumberController,
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
              FloorSaveBar(onSave: _saveFloor),
            ],
          ),
        ),
      ),
    );
  }
}
