import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/presentation/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_bottom_panel.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_top_overlay.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/delegate_map_widgets.dart';
import 'package:baladeyate/features/daily_tasks/presentation/components/start_survey_sheet.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateMapScreen extends StatelessWidget {
  const DelegateMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DelegateMapView();
  }
}

class _DelegateMapView extends StatefulWidget {
  const _DelegateMapView();

  @override
  State<_DelegateMapView> createState() => _DelegateMapViewState();
}

class _DelegateMapViewState extends State<_DelegateMapView> with RouteAware {
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);

  GoogleMapController? _mapController;
  bool _routeSubscribed = false;
  String? _lastFocusedPinId;
  int? _lastShellIndex;

  void _onShellTabChanged(int? index) {
    if (index != DelegateShellIndices.map) {
      _mapController = null;
      return;
    }
    if (_lastShellIndex == DelegateShellIndices.map) return;
    _lastFocusedPinId = null;

    if (mounted) {
      final cubit = context.read<DailyTasksCubit>();
      cubit.loadPins();
      cubit.loadTasks();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _animateToCurrentLocation(animate: false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final shell = StatefulNavigationShell.maybeOf(context);
    final index = shell?.currentIndex;
    _onShellTabChanged(index);
    _lastShellIndex = index;
    if (_routeSubscribed) return;
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      appRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    final cubit = context.read<DailyTasksCubit>();
    cubit.loadPins();
    cubit.loadTasks();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _animateToCurrentLocation({required bool animate}) async {
    final cubit = context.read<DailyTasksCubit>();
    final latLng = await cubit.moveToCurrentLocation();
    if (!mounted || latLng == null || _mapController == null) return;

    final update = CameraUpdate.newCameraPosition(
      CameraPosition(target: latLng, zoom: 14.5),
    );
    if (animate) {
      await _mapController!.animateCamera(update);
    } else {
      await _mapController!.moveCamera(update);
    }
  }

  Future<void> _handleMapLongPress(LatLng position) async {
    final cubit = context.read<DailyTasksCubit>();
    if (!cubit.state.isAddPinMode) return;

    final confirmed = await showStartSurveySheet(context, position: position);
    if (confirmed != true || !mounted) return;

    final pinId = 'pin_${DateTime.now().millisecondsSinceEpoch}';
    await cubit.saveDraftPin(
      pinId: pinId,
      latitude: position.latitude,
      longitude: position.longitude,
    );
    if (!mounted) return;

    await context.push(
      '/info',
      extra: SurveyLocation(
        pinId: pinId,
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
    if (!mounted) return;
    await cubit.loadPins();
  }

  Future<void> _focusPin(SurveyPin pin) async {
    _lastFocusedPinId = pin.id;
    await focusDelegatePin(
        _mapController, context.read<DailyTasksCubit>(), pin);
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (!mounted) return;
    final cubit = context.read<DailyTasksCubit>();
    final currentPosition = cubit.state.currentPosition;
    if (currentPosition != null) {
      await controller.moveCamera(
        CameraUpdate.newLatLngZoom(currentPosition, 14.5),
      );
    }
    if (!mounted) return;
    final selectedPinId = cubit.state.selectedPinId;
    if (selectedPinId != null) {
      final pin =
          cubit.state.pins.where((p) => p.id == selectedPinId).firstOrNull;
      if (pin != null) {
        await _focusPin(pin);
      }
    }
  }

  void _maybeFocusSelectedPin(String? selectedPinId, List<SurveyPin> pins) {
    if (selectedPinId == null || selectedPinId == _lastFocusedPinId) return;
    final pin = pins.where((p) => p.id == selectedPinId).firstOrNull;
    if (pin == null) return;
    _lastFocusedPinId = selectedPinId;
    _focusPin(pin);
  }

  Future<void> _onSelectedPinAction(SurveyPin pin) async {
    await resumeDelegateSurvey(
      context,
      pin,
      onFocusPin: _focusPin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final shell = StatefulNavigationShell.maybeOf(context);
    final isMapTabActive =
        shell == null || shell.currentIndex == DelegateShellIndices.map;

    return MultiBlocListener(
      listeners: [
        BlocListener<DailyTasksCubit, DailyTasksState>(
          listenWhen: (previous, current) =>
              previous.currentPosition == null &&
              current.currentPosition != null,
          listener: (context, state) {
            if (_mapController != null && state.currentPosition != null) {
              _mapController!.animateCamera(
                CameraUpdate.newLatLngZoom(state.currentPosition!, 14.5),
              );
            }
          },
        ),
        BlocListener<DailyTasksCubit, DailyTasksState>(
          listenWhen: (previous, current) =>
              previous.selectedPinId != current.selectedPinId &&
              current.selectedPinId != null,
          listener: (context, state) {
            _maybeFocusSelectedPin(state.selectedPinId, state.pins);
          },
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (isMapTabActive)
              RepaintBoundary(
                child: BlocSelector<
                    DailyTasksCubit,
                    DailyTasksState,
                    ({
                      List<SurveyPin> pins,
                      String? selectedPinId,
                      MapType mapType,
                      bool isAddPinMode,
                    })>(
                  selector: (state) => (
                    pins: state.visiblePins,
                    selectedPinId: state.selectedPinId,
                    mapType: state.mapType,
                    isAddPinMode: state.isAddPinMode,
                  ),
                  builder: (context, mapData) {
                    final navClearance =
                        DelegateBottomNavigationBar.clearance(context);
                    return DelegateSurveyMap(
                      key: const ValueKey('delegate_survey_map'),
                      defaultCenter: _defaultCenter,
                      pins: mapData.pins,
                      selectedPinId: mapData.selectedPinId,
                      mapType: mapData.mapType,
                      isAddPinMode: mapData.isAddPinMode,
                      bottomPadding: navClearance +
                          (mapData.selectedPinId != null
                              ? 160.h(context)
                              : 16.h(context)),
                      onMapCreated: _onMapCreated,
                      onTap: () =>
                          context.read<DailyTasksCubit>().selectPin(null),
                      onLongPress: _handleMapLongPress,
                      onMarkerTap: _focusPin,
                    );
                  },
                ),
              )
            else
              const ColoredBox(color: Color(0xFFE8E8E8)),
            const DelegateMapTopOverlay(),
            DelegateMapBottomPanel(
              onLocateTap: () => _animateToCurrentLocation(animate: true),
              onSelectedPinAction: _onSelectedPinAction,
            ),
          ],
        ),
      ),
    );
  }
}
