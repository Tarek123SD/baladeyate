import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/widgets/custom_daily_task_card.dart';
import 'package:baladeyate/core/widgets/custom_track_statistic_card.dart';
import 'package:baladeyate/features/daily_tasks/models/daily_task.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DailyTasksScreen extends StatefulWidget {
  const DailyTasksScreen({super.key});

  @override
  State<DailyTasksScreen> createState() => _DailyTasksScreenState();
}

class _DailyTasksScreenState extends State<DailyTasksScreen> {
  static const LatLng _defaultCenter = LatLng(33.5138, 36.2765);

  static const double _sheetMinSize = 0.24;
  static const double _sheetInitialSize = 0.42;
  static const double _sheetMaxSize = 0.92;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  LatLng? _currentPosition;
  String? _selectedTaskId;
  bool _isLocating = false;
  String? _locationMessage;

  late final List<DailyTask> _tasks = [
    const DailyTask(
      id: 'task-1',
      title: 'مسح المنشأة التعليمية #412',
      location: 'حي المزة، دمشق',
      distance: '1.2 كم',
      time: '09:30 ص',
      status: DailyTaskStatus.highPriority,
      position: LatLng(33.5182, 36.2688),
    ),
    const DailyTask(
      id: 'task-2',
      title: 'معاينة المتجر التجاري #88',
      location: 'شارع بغداد',
      distance: '2.5 كم',
      time: '11:15 ص',
      status: DailyTaskStatus.scheduled,
      position: LatLng(33.5089, 36.2915),
    ),
    const DailyTask(
      id: 'task-3',
      title: 'تفتيش المركز اللوجستي',
      location: 'المنطقة الصناعية',
      distance: '3.1 كم',
      time: '08:00 ص',
      status: DailyTaskStatus.completed,
      position: LatLng(33.4998, 36.2542),
    ),
  ];

  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((task) => task.isCompleted).length;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    _initLocation();
  }

  @override
  void dispose() {
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

  Future<void> _focusTask(DailyTask task, {bool expandSheet = false}) async {
    setState(() => _selectedTaskId = task.id);

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: task.position, zoom: 15.5),
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

  void _toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  Set<Marker> _buildMarkers() {
    return _tasks.map((task) {
      final isSelected = task.id == _selectedTaskId;
      return Marker(
        markerId: MarkerId(task.id),
        position: task.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(task.status)),
        alpha: task.isCompleted ? 0.55 : 1,
        zIndexInt: isSelected ? 2 : 1,
        onTap: () => _focusTask(task, expandSheet: true),
        infoWindow: InfoWindow(
          title: task.title,
          snippet: task.location,
        ),
      );
    }).toSet();
  }

  double _markerHue(DailyTaskStatus status) {
    switch (status) {
      case DailyTaskStatus.highPriority:
        return BitmapDescriptor.hueRed;
      case DailyTaskStatus.scheduled:
        return BitmapDescriptor.hueOrange;
      case DailyTaskStatus.completed:
        return BitmapDescriptor.hueGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final achievement =
        ((_completedTasks / _totalTasks) * 100).round().toString();
    final horizontalPadding = context.isMobile ? 16.w(context) : 24.w(context);
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
      onTap: (_) => setState(() => _selectedTaskId = null),
    );
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
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
                  color: AppColors.primaryForest,
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
                ..._tasks.map((task) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h(context)),
                    child: CustomDailyTaskCard(
                      title: task.title,
                      location: task.location,
                      distance: task.distance,
                      time: task.time,
                      status: task.status,
                      isSelected: task.id == _selectedTaskId,
                      onTap: () => _focusTask(task),
                      onStart: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('بدء مهمة: ${task.title}')),
                        );
                      },
                      onNavigate: () => _focusTask(task),
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
                                    task.title,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: AppColors.primaryForest,
                                      fontSize: 17.f(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 8.h(context)),
                                  Text(
                                    task.location,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: AppColors.secondaryCharcoal
                                          .withValues(alpha: 0.8),
                                      fontSize: 14.f(context),
                                    ),
                                  ),
                                  SizedBox(height: 8.h(context)),
                                  Text(
                                    'المسافة: ${task.distance} • الوقت: ${task.time}',
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
