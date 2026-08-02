import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/widgets/delegate_bottom_navigation_bar.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_map_widgets.dart';
import 'package:baladeyate/features/daily_tasks/widgets/start_survey_sheet.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
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
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    8.h(context),
                    horizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocSelector<DailyTasksCubit, DailyTasksState,
                          ({int totalTasks, int completedTasks})>(
                        selector: (state) => (
                          totalTasks: state.totalTasks,
                          completedTasks: state.completedTasks,
                        ),
                        builder: (context, stats) {
                          return _DelegateMapHeader(
                            completedTasks: stats.completedTasks,
                            totalTasks: stats.totalTasks,
                          );
                        },
                      ),
                      SizedBox(height: 8.h(context)),
                      BlocSelector<DailyTasksCubit, DailyTasksState,
                          SurveyPinStatus?>(
                        selector: (state) => state.pinStatusFilter,
                        builder: (context, filter) {
                          return DelegateMapFilterChips(
                            selected: filter,
                            onChanged: context
                                .read<DailyTasksCubit>()
                                .setPinStatusFilter,
                          );
                        },
                      ),
                      BlocSelector<DailyTasksCubit, DailyTasksState,
                          ({bool isAddPinMode, String? locationMessage})>(
                        selector: (state) => (
                          isAddPinMode: state.isAddPinMode,
                          locationMessage: state.locationMessage,
                        ),
                        builder: (context, banners) {
                          if (banners.isAddPinMode) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h(context)),
                              child: DelegateAddPinBanner(
                                onCancel: () => context
                                    .read<DailyTasksCubit>()
                                    .toggleAddPinMode(),
                              ),
                            );
                          }
                          if (banners.locationMessage != null) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h(context)),
                              child: DelegateLocationBanner(
                                message: banners.locationMessage!,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom:
                  DelegateBottomNavigationBar.clearance(context) + 8.h(context),
              child: BlocSelector<DailyTasksCubit, DailyTasksState, SurveyPin?>(
                selector: (state) => state.selectedPin,
                builder: (context, selectedPin) {
                  final hasSelection = selectedPin != null;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BlocSelector<
                              DailyTasksCubit,
                              DailyTasksState,
                              ({
                                bool isLocating,
                                bool isAddPinMode,
                                MapType mapType,
                              })>(
                            selector: (state) => (
                              isLocating: state.isLocating,
                              isAddPinMode: state.isAddPinMode,
                              mapType: state.mapType,
                            ),
                            builder: (context, controls) {
                              final cubit = context.read<DailyTasksCubit>();
                              final isHybrid =
                                  controls.mapType != MapType.normal;
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DelegateMapControlButton(
                                    icon: controls.isLocating
                                        ? null
                                        : Icons.my_location_rounded,
                                    isLoading: controls.isLocating,
                                    tooltip: 'موقعي الحالي',
                                    onTap: () => _animateToCurrentLocation(
                                      animate: true,
                                    ),
                                  ),
                                  SizedBox(height: 8.h(context)),
                                  DelegateMapControlButton(
                                    icon: isHybrid
                                        ? Icons.map_rounded
                                        : Icons.layers_rounded,
                                    isActive: isHybrid,
                                    tooltip: isHybrid
                                        ? 'عرض الخريطة العادية'
                                        : 'عرض القمر الصناعي',
                                    onTap: cubit.toggleMapType,
                                  ),
                                  SizedBox(height: 8.h(context)),
                                  DelegateMapControlButton(
                                    icon: Icons.add_location_alt_rounded,
                                    onTap: cubit.toggleAddPinMode,
                                    isActive: controls.isAddPinMode,
                                    tooltip: controls.isAddPinMode
                                        ? 'إلغاء وضع الإضافة'
                                        : 'إضافة نقطة مسح',
                                  ),
                                ],
                              );
                            },
                          ),
                          const Spacer(),
                          if (!hasSelection) const DelegateMapStatusLegend(),
                        ],
                      ),
                      if (hasSelection) ...[
                        SizedBox(height: 10.h(context)),
                        DelegateSelectedPinCard(
                          pin: selectedPin,
                          onClose: () =>
                              context.read<DailyTasksCubit>().selectPin(null),
                          onAction: () => _onSelectedPinAction(selectedPin),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DelegateMapHeader extends StatelessWidget {
  const _DelegateMapHeader({
    required this.completedTasks,
    required this.totalTasks,
  });

  final int completedTasks;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (previous, current) {
        if (previous is AuthSuccess && current is AuthSuccess) {
          return previous.user.name != current.user.name;
        }
        return previous.runtimeType != current.runtimeType;
      },
      builder: (context, authState) {
        final userName =
            authState is AuthSuccess ? authState.user.name : 'مندوب';
        final initial = userName.isNotEmpty ? userName.characters.first : 'م';
        final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(20.r(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 10.h(context),
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CircleAvatar(
                  radius: 20.s(context),
                  backgroundColor:
                      AppColors.thirdForest.withValues(alpha: 0.18),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 16.f(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.h(context)),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r(context)),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 6.h(context),
                                backgroundColor: AppColors.thirdGoldenWheat
                                    .withValues(alpha: 0.7),
                                color: AppColors.primaryForest,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w(context)),
                          Text(
                            '$completedTasks/$totalTasks',
                            style: TextStyle(
                              color: AppColors.primaryForest,
                              fontSize: 11.f(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w(context)),
                Material(
                  color: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => context.push('/notifications'),
                    child: Padding(
                      padding: EdgeInsets.all(9.s(context)),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primaryForest,
                        size: 20.ic(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
