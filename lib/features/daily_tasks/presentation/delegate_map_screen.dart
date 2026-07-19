import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_cubit.dart';
import 'package:baladeyate/features/daily_tasks/cubits/daily_tasks_cubit/daily_tasks_state.dart';
import 'package:baladeyate/features/daily_tasks/utils/delegate_survey_actions.dart';
import 'package:baladeyate/features/daily_tasks/widgets/delegate_map_widgets.dart';
import 'package:baladeyate/features/daily_tasks/widgets/start_survey_sheet.dart';
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
    await focusDelegatePin(_mapController, context.read<DailyTasksCubit>(), pin);
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
      final pin = cubit.state.pins
          .where((p) => p.id == selectedPinId)
          .firstOrNull;
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
              !previous.isAddPinMode && current.isAddPinMode,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('اضغط مطولاً على الخريطة لإضافة نقطة مسح'),
              ),
            );
          },
        ),
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
                child: BlocSelector<DailyTasksCubit, DailyTasksState,
                    ({List<SurveyPin> pins, String? selectedPinId, MapType mapType})>(
                  selector: (state) => (
                    pins: state.pins,
                    selectedPinId: state.selectedPinId,
                    mapType: state.mapType,
                  ),
                  builder: (context, mapData) {
                    return DelegateSurveyMap(
                      key: const ValueKey('delegate_survey_map'),
                      defaultCenter: _defaultCenter,
                      pins: mapData.pins,
                      selectedPinId: mapData.selectedPinId,
                      mapType: mapData.mapType,
                      bottomPadding: 100.h(context),
                      onMapCreated: _onMapCreated,
                      onTap: () =>
                          context.read<DailyTasksCubit>().selectPin(null),
                      onLongPress: _handleMapLongPress,
                      onMarkerTap: (pin) => _focusPin(pin),
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
                    12.h(context),
                  ),
                  child: BlocSelector<DailyTasksCubit, DailyTasksState,
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
                ),
              ),
            ),
            BlocSelector<DailyTasksCubit, DailyTasksState, String?>(
              selector: (state) => state.locationMessage,
              builder: (context, locationMessage) {
                if (locationMessage == null) return const SizedBox.shrink();
                return Positioned(
                  top: MediaQuery.paddingOf(context).top + 78.h(context),
                  left: horizontalPadding,
                  right: horizontalPadding,
                  child: DelegateLocationBanner(message: locationMessage),
                );
              },
            ),
            Positioned(
              left: horizontalPadding,
              bottom: 16.h(context),
              child: BlocSelector<DailyTasksCubit, DailyTasksState,
                  ({bool isLocating, bool isAddPinMode})>(
                selector: (state) => (
                  isLocating: state.isLocating,
                  isAddPinMode: state.isAddPinMode,
                ),
                builder: (context, controls) {
                  final cubit = context.read<DailyTasksCubit>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DelegateMapControlButton(
                        icon: controls.isLocating
                            ? null
                            : Icons.my_location_rounded,
                        isLoading: controls.isLocating,
                        onTap: () => _animateToCurrentLocation(animate: true),
                      ),
                      SizedBox(height: 8.h(context)),
                      DelegateMapControlButton(
                        icon: Icons.layers_rounded,
                        onTap: cubit.toggleMapType,
                      ),
                      SizedBox(height: 8.h(context)),
                      DelegateMapControlButton(
                        icon: Icons.add_location_alt_rounded,
                        onTap: cubit.toggleAddPinMode,
                        isActive: controls.isAddPinMode,
                      ),
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

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
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
                  radius: 22.s(context),
                  backgroundColor:
                      AppColors.thirdForest.withValues(alpha: 0.18),
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.primaryForest,
                      fontSize: 18.f(context),
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
                      SizedBox(height: 2.h(context)),
                      Text(
                        _formatToday(),
                        style: TextStyle(
                          color: AppColors.secondaryCharcoal
                              .withValues(alpha: 0.65),
                          fontSize: 11.f(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w(context)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w(context),
                    vertical: 7.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(24.r(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.s(context),
                        height: 8.s(context),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryGoldenWheat,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w(context)),
                      Text(
                        '$completedTasks/$totalTasks مكتمل',
                        style: TextStyle(
                          color: AppColors.primaryForest,
                          fontSize: 11.f(context),
                          fontWeight: FontWeight.w700,
                        ),
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

  String _formatToday() {
    const weekdays = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final now = DateTime.now();
    return '${weekdays[now.weekday % 7]}، ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
