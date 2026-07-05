import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:baladeyate/features/daily_tasks/widgets/start_survey_sheet.dart';
import 'package:baladeyate/features/delegate/cubits/delegate_tasks_cubit/delegate_tasks_cubit.dart';
import 'package:baladeyate/features/delegate/models/survey_location.dart';
import 'package:baladeyate/features/delegate/models/survey_pin.dart';
import 'package:baladeyate/features/delegate/models/survey_pin_status.dart';
import 'package:baladeyate/features/delegate/repo/delegate_repository.dart';
import 'package:baladeyate/routes/app_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DelegateTasksCubit>()..loadTasks(),
      child: const _DailyTasksView(),
    );
  }
}

class _DailyTasksView extends StatefulWidget {
  const _DailyTasksView();

  @override
  State<_DailyTasksView> createState() => _DailyTasksViewState();
}

class _DailyTasksViewState extends State<_DailyTasksView> with RouteAware {
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);

  static const double _sheetMinSize = 0.24;
  static const double _sheetInitialSize = 0.42;
  static const double _sheetMaxSize = 0.92;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  LatLng? _currentPosition;
  String? _selectedPinId;
  bool _isLocating = false;
  bool _isLoadingPins = false;
  bool _isAddPinMode = false;
  String? _locationMessage;
  List<SurveyPin> _pins = [];

  final DelegateRepository _delegateRepository = sl<DelegateRepository>();

  int get _totalTasks => _pins.length;
  int get _completedTasks =>
      _pins.where((pin) => pin.status == SurveyPinStatus.completed).length;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    _initLocation();
    _loadPins();
  }

  bool _routeSubscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _loadPins();
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = 'يرجى تفعيل خدمة الموقع';
      });
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = 'لم يتم منح إذن الموقع';
      });
      return;
    }

    await _moveToCurrentLocation(animate: false);
  }

  Future<void> _moveToCurrentLocation({required bool animate}) async {
    setState(() => _isLocating = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = latLng;
        _locationMessage = null;
      });

      if (_mapController != null) {
        final update = CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: 14.5),
        );
        if (animate) {
          await _mapController!.animateCamera(update);
        } else {
          await _mapController!.moveCamera(update);
        }
      }
    } catch (_) {
      setState(() {
        _locationMessage = 'تعذر تحديد موقعك الحالي';
      });
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _loadPins() async {
    setState(() => _isLoadingPins = true);
    try {
      final pins = await _delegateRepository.getMapPins();
      if (mounted) {
        setState(() => _pins = pins);
      }
    } finally {
      if (mounted) setState(() => _isLoadingPins = false);
    }
  }

  Future<void> _handleMapLongPress(LatLng position) async {
    if (!_isAddPinMode) return;

    final confirmed = await showStartSurveySheet(context, position: position);
    if (confirmed != true || !mounted) return;

    final pinId = 'pin_${DateTime.now().millisecondsSinceEpoch}';
    final draftPin = SurveyPin(
      id: pinId,
      latitude: position.latitude,
      longitude: position.longitude,
      status: SurveyPinStatus.inProgress,
      title: 'مسح جديد',
    );

    await _delegateRepository.saveDraftPin(draftPin);
    if (!mounted) return;

    await context.push(
      '/info',
      extra: SurveyLocation(
        pinId: pinId,
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );
    await _loadPins();
  }

  Future<void> _resumeSurvey(SurveyPin pin) async {
    if (pin.status == SurveyPinStatus.completed) {
      await _focusPin(pin);
      return;
    }

    await context.push(
      '/info',
      extra: SurveyLocation(
        pinId: pin.id,
        latitude: pin.latitude,
        longitude: pin.longitude,
      ),
    );
    await _loadPins();
  }

  Future<void> _focusPin(SurveyPin pin, {bool expandSheet = false}) async {
    setState(() => _selectedPinId = pin.id);

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pin.position, zoom: 15.5),
      ),
    );

    if (expandSheet && _sheetController.isAttached) {
      await _sheetController.animateTo(
        _sheetInitialSize,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    }
  }

  void _toggleAddPinMode() {
    setState(() => _isAddPinMode = !_isAddPinMode);
    if (_isAddPinMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اضغط مطولاً على الخريطة لإضافة نقطة مسح'),
        ),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    return _pins.map((pin) {
      final isSelected = pin.id == _selectedPinId;
      return Marker(
        markerId: MarkerId(pin.id),
        position: pin.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(pin.status)),
        alpha: pin.status == SurveyPinStatus.completed ? 0.85 : 1,
        zIndexInt: isSelected ? 2 : 1,
        onTap: () => _focusPin(pin, expandSheet: true),
        infoWindow: InfoWindow(
          title: pin.displayTitle,
          snippet: pin.displayLocation,
        ),
      );
    }).toSet();
  }

  double _markerHue(SurveyPinStatus status) {
    switch (status) {
      case SurveyPinStatus.assigned:
        return BitmapDescriptor.hueRed;
      case SurveyPinStatus.inProgress:
        return BitmapDescriptor.hueOrange;
      case SurveyPinStatus.completed:
        return BitmapDescriptor.hueGreen;
    }
  }

  DailyTaskStatus _cardStatusForPin(SurveyPin pin) {
    switch (pin.status) {
      case SurveyPinStatus.assigned:
        return DailyTaskStatus.highPriority;
      case SurveyPinStatus.inProgress:
        return DailyTaskStatus.scheduled;
      case SurveyPinStatus.completed:
        return DailyTaskStatus.completed;
    }
  }

  String _statusLabel(SurveyPin pin) {
    switch (pin.status) {
      case SurveyPinStatus.assigned:
        return 'مهمة ميدانية';
      case SurveyPinStatus.inProgress:
        return 'قيد الإدخال';
      case SurveyPinStatus.completed:
        return 'مكتمل';
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievement = _totalTasks == 0
        ? '0'
        : ((_completedTasks / _totalTasks) * 100).round().toString();
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetSize =
        _sheetController.isAttached ? _sheetController.size : _sheetInitialSize;
    final controlsBottom = (screenHeight * sheetSize) + 16.h(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _buildMap()),
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
                child: _buildHeader(context),
              ),
            ),
          ),
          if (_locationMessage != null)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 78.h(context),
              left: horizontalPadding,
              right: horizontalPadding,
              child: _buildLocationBanner(context),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            left: horizontalPadding,
            bottom: controlsBottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMapControlButton(
                  context,
                  icon: _isLocating ? null : Icons.my_location_rounded,
                  isLoading: _isLocating,
                  onTap: () => _moveToCurrentLocation(animate: true),
                ),
                SizedBox(height: 8.h(context)),
                _buildMapControlButton(
                  context,
                  icon: Icons.layers_rounded,
                  onTap: _toggleMapType,
                ),
                SizedBox(height: 8.h(context)),
                _buildMapControlButton(
                  context,
                  icon: Icons.add_location_alt_rounded,
                  onTap: _toggleAddPinMode,
                  isActive: _isAddPinMode,
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _sheetInitialSize,
            minChildSize: _sheetMinSize,
            maxChildSize: _sheetMaxSize,
            snap: true,
            snapSizes: const [_sheetMinSize, _sheetInitialSize, _sheetMaxSize],
            builder: (context, scrollController) {
              return _buildTasksSheet(
                context,
                scrollController: scrollController,
                achievement: achievement,
                horizontalPadding: horizontalPadding,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _defaultCenter,
        zoom: 13.5,
      ),
      mapType: _mapType,
      markers: _buildMarkers(),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      padding: EdgeInsets.only(bottom: 220.h(context)),
      onMapCreated: (controller) async {
        _mapController = controller;
        if (_currentPosition != null) {
          await controller.moveCamera(
            CameraUpdate.newLatLngZoom(_currentPosition!, 14.5),
          );
        }
      },
      onTap: (_) => setState(() => _selectedPinId = null),
      onLongPress: _handleMapLongPress,
    );
  }

  void _toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  Widget _buildHeader(BuildContext context) {
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
              backgroundColor: AppColors.thirdForest.withValues(alpha: 0.18),
              child: Text(
                'أ',
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
                    'أحمد منصور',
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
                    'الأحد، 20 أكتوبر 2024',
                    style: TextStyle(
                      color:
                          AppColors.secondaryCharcoal.withValues(alpha: 0.65),
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
                    '$_completedTasks/$_totalTasks مكتمل',
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
  }

  Widget _buildLocationBanner(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(12.r(context)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12.w(context),
          vertical: 10.h(context),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: AppColors.primaryGoldenWheat,
              size: 18.ic(context),
            ),
            SizedBox(width: 8.w(context)),
            Expanded(
              child: Text(
                _locationMessage!,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.primaryForest,
                  fontSize: 12.f(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControlButton(
    BuildContext context, {
    IconData? icon,
    bool isLoading = false,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryForest : Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: EdgeInsets.all(11.s(context)),
          child: isLoading
              ? SizedBox(
                  width: 20.s(context),
                  height: 20.s(context),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  icon,
                  size: 20.ic(context),
                  color:
                      isActive ? Colors.white : AppColors.primaryForest,
                ),
        ),
      ),
    );
  }

  Widget _buildTasksSheet(
    BuildContext context, {
    required ScrollController scrollController,
    required String achievement,
    required double horizontalPadding,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.r(context)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10.h(context)),
          Container(
            width: 46.w(context),
            height: 5.h(context),
            decoration: BoxDecoration(
              color: AppColors.secondaryCharcoal.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 14.h(context)),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                28.h(context),
              ),
              children: [
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    CustomTrackStatisticCard(
                      title: 'الإجمالي',
                      value: '$_totalTasks',
                      backgroundColor: Colors.white,
                      textColor: AppColors.primaryForest,
                    ),
                    SizedBox(width: 10.w(context)),
                    CustomTrackStatisticCard(
                      title: 'مكتمل',
                      value: '$_completedTasks',
                      backgroundColor:
                          AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
                      textColor: AppColors.primaryForest,
                    ),
                    SizedBox(width: 10.w(context)),
                    CustomTrackStatisticCard(
                      title: 'الإنجاز',
                      value: '$achievement%',
                      backgroundColor:
                          AppColors.thirdGoldenWheat.withValues(alpha: 0.75),
                      textColor: AppColors.primaryGoldenWheat,
                    ),
                  ],
                ),
                SizedBox(height: 22.h(context)),
                Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'المهام الميدانية',
                      style: TextStyle(
                        color: AppColors.primaryForest,
                        fontSize: 18.f(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w(context),
                        vertical: 6.h(context),
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.thirdGoldenWheat.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20.r(context)),
                      ),
                      child: Text(
                        'اليوم',
                        style: TextStyle(
                          color: AppColors.secondaryCharcoal
                              .withValues(alpha: 0.75),
                          fontSize: 12.f(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h(context)),
                if (_isLoadingPins)
                  const Center(child: CircularProgressIndicator())
                else if (_pins.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h(context)),
                    child: Text(
                      'لا توجد نقاط مسح بعد. فعّل وضع الإضافة واضغط مطولاً على الخريطة.',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: AppColors.secondaryCharcoal.withValues(alpha: 0.7),
                        fontSize: 14.f(context),
                      ),
                    ),
                  )
                else
                  ..._pins.map((pin) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h(context)),
                      child: CustomDailyTaskCard(
                        title: pin.displayTitle,
                        location: pin.displayLocation,
                        distance: _statusLabel(pin),
                        time: pin.status == SurveyPinStatus.completed
                            ? 'محفوظ'
                            : 'مفتوح',
                        status: _cardStatusForPin(pin),
                        isSelected: pin.id == _selectedPinId,
                        onTap: () => _focusPin(pin),
                        onStart: () => _resumeSurvey(pin),
                        onNavigate: () => _focusPin(pin),
                        onInfo: () {
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            backgroundColor: Colors.white,
                            builder: (sheetContext) {
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  20.w(context),
                                  8.h(context),
                                  20.w(context),
                                  24.h(context),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      pin.displayTitle,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: AppColors.primaryForest,
                                        fontSize: 17.f(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h(context)),
                                    Text(
                                      pin.displayLocation,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: AppColors.secondaryCharcoal
                                            .withValues(alpha: 0.8),
                                        fontSize: 14.f(context),
                                      ),
                                    ),
                                    SizedBox(height: 8.h(context)),
                                    Text(
                                      'الحالة: ${_statusLabel(pin)}',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                        color: AppColors.secondaryCharcoal
                                            .withValues(alpha: 0.7),
                                        fontSize: 13.f(context),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
