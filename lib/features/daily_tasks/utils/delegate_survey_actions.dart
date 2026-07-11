import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/data/local_building_survey_store.dart';
import 'package:baladeyate/features/delegate/models/survey_phase.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<void> resumeDelegateSurvey(
  BuildContext context,
  SurveyPin pin, {
  Future<void> Function(SurveyPin pin)? onFocusPin,
}) async {
  final cubit = context.read<DailyTasksCubit>();

  if (pin.status == SurveyPinStatus.completed) {
    if (onFocusPin != null) {
      await onFocusPin(pin);
    } else {
      cubit.selectPin(pin.id);
    }
    return;
  }

  final surveyStore = sl<LocalBuildingSurveyStore>();
  final survey = await surveyStore.loadSurvey(pin.id);

  if (!context.mounted) return;

  if (survey != null && survey.phase != SurveyPhase.buildingPending) {
    await context.push('/building/${pin.id}');
  } else {
    await context.push(
      '/info',
      extra: SurveyLocation(
        pinId: pin.id,
        latitude: pin.latitude,
        longitude: pin.longitude,
      ),
    );
  }
  if (!context.mounted) return;
  await cubit.loadPins();
}

Future<void> focusDelegatePin(
  GoogleMapController? mapController,
  DailyTasksCubit cubit,
  SurveyPin pin,
) async {
  cubit.selectPin(pin.id);
  await mapController?.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: pin.position, zoom: 15.5),
    ),
  );
}
