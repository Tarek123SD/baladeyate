import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/cubits/building_survey_cubit/building_survey_cubit.dart';
import 'package:baladeyate/features/delegate/models/building_survey.dart';
import 'package:baladeyate/features/delegate/models/survey_navigation_context.dart';
import 'package:baladeyate/features/delegate/presentation/components/people_form_body.dart';
import 'package:baladeyate/features/delegate/presentation/components/people_save_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  late TextEditingController _headNationalIdController;
  late TextEditingController _headFullNameController;

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
    _headNationalIdController =
        TextEditingController(text: unit?.headNationalId ?? '');
    _headFullNameController =
        TextEditingController(text: unit?.headFullName ?? '');
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
          headNationalId: _headNationalIdController.text.trim(),
          headFullName: _headFullNameController.text.trim(),
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
    _headNationalIdController.dispose();
    _headFullNameController.dispose();
    super.dispose();
  }

  Widget _buildForm(BuildContext context) {
    final survey = _readSurvey();
    final unit = _readCurrentUnit();
    final floorLocalId = widget.navigationContext?.floorLocalId;
    final floor = floorLocalId != null && survey != null
        ? survey.floorByLocalId(floorLocalId)
        : null;

    return PeopleFormBody(
      isStandalone: _isStandalone,
      survey: survey,
      floor: floor,
      unit: unit,
      isDataVerified: _isDataVerified,
      familyBookController: _familyBookController,
      unemployedCountController: _unemployedCountController,
      studentsCountController: _studentsCountController,
      familyMembersCountController: _familyMembersCountController,
      residentsCountController: _residentsCountController,
      compositionController: _compositionController,
      headNationalIdController: _headNationalIdController,
      headFullNameController: _headFullNameController,
      onSyncText: _syncText,
      onPickAidDate: _pickAidDate,
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
                  PeopleSaveBar(
                    isSaving: isSaving,
                    isUpdate: isUpdate,
                    onSave: _saveUnit,
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
